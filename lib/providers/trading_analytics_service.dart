import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $pb_struct;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $pb_ts;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/period_type.dart';
import '../model/proto/generated/portfolio.pb.dart' as $pb;
import '../model/proto/generated/portfolio.pbgrpc.dart';
import '../model/proto/logging_interceptor.dart';
import '../model/proto/generated/price.pb.dart' as $pb_price;
import '../model/results/indicator/price_result.dart' as model_price;
import '../model/results/portfolio_result.dart' as model_result;
import '../model/portfolio_schema.dart';
import '../model/results/strategies/strategy_schema.dart' as model_strategy;
import '../model/results/asset_allocation.dart'  as model_allocations;

part 'trading_analytics_service.g.dart';

typedef TradingAnalyticsServiceClient = AnalyticsServiceClient;

// Use '10.0.2.2' for Android emulator to reach host's localhost, and '127.0.0.1' for other platforms.
final String defaultHost = String.fromEnvironment(
    'GRPC_HOST',
    defaultValue: Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'
);

final int defaultPort = 50052;

@riverpod
TradingAnalyticsServiceClient tradingAnalyticsClient(
    Ref ref, [String? customHost, int? customPort]) {
  final host = customHost ?? defaultHost;
  final port = customPort ?? defaultPort;
  final channel = ClientChannel(
    host,
    port: port,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      idleTimeout: Duration(minutes: 5),
    ),
  );
  ref.onDispose(() {
    log("Trading analysis gRPC channel shutting down");
    channel.shutdown();
  });

  return TradingAnalyticsServiceClient(
    channel,
    interceptors: [GrpcLoggingInterceptor()],
  );
}

@riverpod
class ActiveRiskPortfolioId extends _$ActiveRiskPortfolioId {
  @override
  int? build() => null;

  void select(int id) => state = id;
}

@immutable
class TradingAnalyticsServiceState {
  final String? error;
  final model_result.PortfolioResultMap cache;

  const TradingAnalyticsServiceState({this.cache = const {}, this.error});

}

@riverpod
class TradingAnalyticsService extends _$TradingAnalyticsService {
  late TradingAnalyticsServiceClient _client;
  StreamController<$pb.EvaluatePortfolioRequest>? _outgoingController;
  StreamSubscription? _incomingSubscription;

  @override
  TradingAnalyticsServiceState build() {
    _client = ref.watch(tradingAnalyticsClientProvider());
    ref.onDispose(() {
      _incomingSubscription?.cancel();
      _incomingSubscription = null;
      _outgoingController?.close();
      _outgoingController = null;
    });
    return const TradingAnalyticsServiceState(cache: {});
  }
  
  void _initStream() {
    if (!ref.mounted) return;

    // Reset existing stream and subscription
    _incomingSubscription?.cancel();
    _incomingSubscription = null;
    
    if (_outgoingController != null && !_outgoingController!.isClosed) {
      _outgoingController!.close();
    }
    
    _outgoingController = StreamController<$pb.EvaluatePortfolioRequest>();
    final controller = _outgoingController!;
    
    try {
      final responseStream = controller.stream.asyncMap(
        (request) => _client.evaluatePortfolio(request)
      );
      
      _incomingSubscription = responseStream.listen(
        (response) {
          if (!ref.mounted) return;

          // Map and update state
          final resId = int.tryParse(response.portfolioId) ?? PortfolioConfig.defaultId;
          final equityCurvePoints = response.equityCurve.map((e) {
            return model_result.EquityCurvePoint(
              timestamp: e.timestamp.toDateTime(),
              portfolioValue: e.portfolioValue,
              drawdown: e.drawdown);
          }).toList();

          final currentCache = state.cache;
          state = TradingAnalyticsServiceState(
            cache: {
              ...currentCache,
              resId: model_result.PortfolioResult(
                portfolioConfig: PortfolioConfig.of(resId),
                performanceMetrics: model_result.PerformanceMetrics(
                  totalReturn: response.summaryMetrics.totalReturn,
                  annualizedReturn: response.summaryMetrics.annualizedReturn,
                  volatility: response.summaryMetrics.volatility,
                  sharpeRatio: response.summaryMetrics.sharpeRatio,
                  sortinoRatio: response.summaryMetrics.sortinoRatio,
                  maxDrawdown: response.summaryMetrics.maxDrawdown,
                  alpha: response.summaryMetrics.alpha,
                  beta: response.summaryMetrics.beta,
                  cagr: response.summaryMetrics.cagr,
                  calmar: response.summaryMetrics.calmar,
                  correlation: response.summaryMetrics.correlation,
                  trackingError: response.summaryMetrics.trackingError,
                  trackingDiff: response.summaryMetrics.trackingDiff,
                  expenseRatio: response.summaryMetrics.expenseRatio,
                  bidAskSpread: response.summaryMetrics.bidAskSpread,
                  concentration: response.summaryMetrics.concentration,
                  dividendYield: response.summaryMetrics.dividendYield,
                ),
                equityCurve: equityCurvePoints,
                calculatedAt: response.calculatedAt.toDateTime(),
              ),
            },
          );
        },
        onError: (error) {
          if (!ref.mounted) return;
          
          String errorMsg = error.toString();
          if (error is GrpcError) {
            errorMsg = _connectionMessage(error);
          }
          
          log("Trading analysis service error: $errorMsg");
          
          final currentCache = state.cache;
          state = TradingAnalyticsServiceState(error: errorMsg, cache: currentCache);
          
          // Close the current subscription/controller on error to allow re-initialization
          _incomingSubscription?.cancel();
          _incomingSubscription = null;
          if (!controller.isClosed) {
            controller.close();
          }
        },
        onDone: () {
          if (!ref.mounted) return;
          log("Trading analysis service: gRPC Stream closed");
          _incomingSubscription = null;
          if (!controller.isClosed) {
            controller.close();
          }
        }
      );
    } catch (e) {
      log("Trading analysis service: Error initializing stream: $e");
    }
  }

  /// Evaluates a specific portfolio strategy based on historical parameters
  Future<void> evaluate(PortfolioConfig portfolio) async {
    try {
      if (!ref.mounted) return;

      final protoPortfolio = await _toProtoPortfolio(portfolio);
      if (!ref.mounted || protoPortfolio == null) return;

      final request = $pb.EvaluatePortfolioRequest(
        portfolio: protoPortfolio, 
        startDate: $pb_ts.Timestamp.fromDateTime(portfolio.startDateTime),
        endDate: $pb_ts.Timestamp.fromDateTime(portfolio.endDateTime),
        strategyConfig: $pb.StrategyConfig(
          strategyType: _toProtoStrategyType(portfolio.strategy!.type),
          rebalanceFrequency: _toRebalanceFrequency(portfolio.getRebalanceFrequency()),
          customParameters: _toProtoStruct(portfolio.strategy?.toMap() ?? {}),
        )
      );

      if (_outgoingController == null || 
          _outgoingController!.isClosed || 
          _incomingSubscription == null) {
        _initStream();
      }

      final controller = _outgoingController;
      if (ref.mounted && controller != null && !controller.isClosed) {
        controller.add(request);
      } else {
        log("Trading analysis service: Cannot add request (controller closed or disposed)");
      }
    } catch (e) {
      log("Trading analysis service: Evaluation error: $e");
      if (ref.mounted) {
        state = TradingAnalyticsServiceState(error: e.toString(), cache: state.cache);
      }
    }


  }

  String _connectionMessage(GrpcError grpcError) {
    return switch (grpcError.code) {
      StatusCode.unavailable => "Server is down or unreachable (check host: $defaultHost).",
      StatusCode.deadlineExceeded => "Request timed out.",
      StatusCode.aborted => "Request aborted.",
      StatusCode.cancelled => "Request cancelled.",
      StatusCode.invalidArgument => "Invalid request parameters.",
      StatusCode.unknown => "Unknown error.",
      StatusCode.internal => "Internal server error.",
      StatusCode.permissionDenied => "Permission denied.",
      StatusCode.resourceExhausted => "Resource limit exceeded.",
      StatusCode.unauthenticated => "Authentication failed.",
      StatusCode.notFound => "Requested resource not found.",
      StatusCode.alreadyExists => "Requested resource already exists.",
      StatusCode.failedPrecondition => "Precondition failed.",
      StatusCode.outOfRange => "Request out of range.",
      StatusCode.unimplemented => "Method not implemented.",
      StatusCode.dataLoss => "Data loss.",
      _ => "Connection error: ${grpcError.code}"
    };
  }

  $pb.StrategyType _toProtoStrategyType(model_strategy.StrategyType type) {
    return switch (type) {
      model_strategy.StrategyType.empty => $pb.StrategyType.EMPTY,
      model_strategy.StrategyType.arbitrary => $pb.StrategyType.ARBITRARY,
      model_strategy.StrategyType.asset => $pb.StrategyType.ASSETALLOCATION,
      model_strategy.StrategyType.gem => $pb.StrategyType.GEM,
      model_strategy.StrategyType.meanReversion => $pb.StrategyType.MEANREVERSION,
      model_strategy.StrategyType.indexFundRebalancing => $pb.StrategyType.INDEXFUNDREBALANCING,
      model_strategy.StrategyType.trendFollowing => $pb.StrategyType.TRENDfOLLOWING,
    };
  }

  $pb.RebalanceFrequency _toRebalanceFrequency(PeriodType type) {
    return switch (type) {
      PeriodType.week => $pb.RebalanceFrequency.WEEKLY,
      PeriodType.month => $pb.RebalanceFrequency.MONTHLY,
      PeriodType.quaterYear => $pb.RebalanceFrequency.QUARTERLY,
      PeriodType.halfYear => $pb.RebalanceFrequency.YEARLY,
      PeriodType.year => $pb.RebalanceFrequency.YEARLY,
      PeriodType.twoYears => $pb.RebalanceFrequency.TWO_YEARS,
      PeriodType.threeYears => $pb.RebalanceFrequency.YEARLY,
      PeriodType.fiveYears => $pb.RebalanceFrequency.YEARLY,
      PeriodType.max => $pb.RebalanceFrequency.SPECIFIC_PERIOD,
      PeriodType.yTd => $pb.RebalanceFrequency.SPECIFIC_PERIOD,
      PeriodType.empty => $pb.RebalanceFrequency.UNSPECIFIED,
    };
  }

  $pb_struct.Struct _toProtoStruct(Map<dynamic, dynamic> map) {
    final struct = $pb_struct.Struct();
    for (final entry in map.entries) {
      struct.fields[entry.key.toString()] = _toProtoValue(entry.value);
    }
    return struct;
  }

  $pb_struct.Value _toProtoValue(dynamic value) {
    final result = $pb_struct.Value();
    if (value == null) {
      result.nullValue = $pb_struct.NullValue.NULL_VALUE;
    } else if (value is bool) {
      result.boolValue = value;
    } else if (value is num) {
      result.numberValue = value.toDouble();
    } else if (value is String) {
      result.stringValue = value;
    } else if (value is Map) {
      result.structValue = _toProtoStruct(value);
    } else if (value is Iterable) {
      result.listValue = $pb_struct.ListValue(
        values: value.map((e) => _toProtoValue(e)).toList(),
      );
    } else {
      result.stringValue = value.toString();
    }
    return result;
  }
  
  $pb_price.IndexPriceItem _toProtoPrice(model_price.IndexPriceItem item) {
    return $pb_price.IndexPriceItem()
      ..id = item.id
      ..assetId = item.assetId
      ..close = item.closePrice
      ..dateTime = $pb_ts.Timestamp.fromDateTime(item.dateTime);
  }
  
  $pb.AssetAllocation _toProtoAssetAllocation(model_allocations.AssetAllocation allocation, List<model_price.IndexPriceItem> price) {
    final reqPrice = price.where((e) => e.assetId == allocation.asset.id).map((e) =>  _toProtoPrice(e)).toList();
    
    return $pb.AssetAllocation(
      assetId: allocation.asset.id,
      targetWeight: allocation.targetWeight,
      assetSharesCount: allocation.assetSharesCount,
      price: reqPrice);
  }
  
  Future<$pb.Portfolio?> _toProtoPortfolio(PortfolioConfig portfolio) async {
    if (!ref.mounted) return null;

    final priceSchema = model_price.IndexPriceSchema();
    final allocations = portfolio.strategy?.getAssetAllocations() ?? [];

    // Access notifier before async gap
    final priceNotifier = ref.read(priceControllerProvider().notifier);

    final protoAllocations = await Future.wait(
      allocations.map((a) async {
        if (!ref.mounted) return null;
        try {
          final prices = await priceNotifier.fetchDateRange(
            priceSchema, a.asset, 
            portfolio.startDateTime.subtract(const Duration(days: 30)), 
            portfolio.endDateTime.add(const Duration(days: 30))
          );
          return _toProtoAssetAllocation(a, prices);
        } catch (e) {
          log("Failed to fetch prices for ${a.asset.id}: $e");
          return null;
        }
      }),
    );

    if (!ref.mounted) return null;

    return $pb.Portfolio()
      ..id = portfolio.id.toString()
      ..name = portfolio.portfolioName
      ..description = portfolio.portfolioDesc
      ..initialCapital = portfolio.initialCapital.amount.toDecimal().toDouble()
      ..riskFreeRate = portfolio.riskFreeRatePerYear
      ..allocations.addAll(protoAllocations.whereType<$pb.AssetAllocation>());
  }
}

/// Provider to watch the result of a specific portfolio evaluation
@riverpod
AsyncValue<model_result.PortfolioResult?> portfolioResult(Ref ref, {required int portfolioId}) {
  final (error, result) = ref.watch(tradingAnalyticsServiceProvider.select(
    (s) => (s.error, s.cache[portfolioId])
  ));

  if (error != null) return AsyncValue.error(error, StackTrace.current);
  if (result == null) return const AsyncValue.loading();
  
  return AsyncValue.data(result);
}
