import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $pb_ts;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/proto/generated/portfolio.pb.dart' as $pb;
import '../model/proto/generated/portfolio.pbgrpc.dart';
import '../model/proto/logging_interceptor.dart';
import '../model/proto/generated/price.pb.dart' as $pb_price;
import '../model/results/indicator/price_result.dart' as model_price;
import '../model/results/portfolio_result.dart';
import '../model/portfolio_schema.dart';
import '../model/results/strategies/strategy_schema.dart' as model_strategy;
import '../model/results/asset_allocation.dart'  as model_allocations;

part 'trading_analytics_service.g.dart';

typedef TradingAnalyticsServiceClient = AnalyticsServiceClient;

// Use 'localhost' as it handles IPv4/IPv6 better on some Linux setups than 127.0.0.1
final String defaultHost = String.fromEnvironment(
    'GRPC_HOST',
    defaultValue: Platform.isAndroid ? '10.0.2.3' : 'localhost'
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
    log("Shutting down gRPC channel");
    channel.shutdown();
  });

  // Interceptors are passed to the Client constructor, not ChannelOptions
  return TradingAnalyticsServiceClient(
    channel,
    interceptors: [GrpcLoggingInterceptor()],
  );
}

@immutable
class TradingAnalyticsServiceState {
  final String? error;
  final PortfolioResultMap cache;

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
      _outgoingController?.close();
    });
    return const TradingAnalyticsServiceState(cache: {});
  }
  
  void _initStream() {
    if (_incomingSubscription != null) return;
    _outgoingController = StreamController<$pb.EvaluatePortfolioRequest>();
    
    try {
      final responseStream = _outgoingController!.stream.asyncMap(
        (request) => _client.evaluatePortfolio(request)
      );
      
      _incomingSubscription = responseStream.listen((response) {
          // Map and update state
          final id = int.tryParse(response.portfolioId) ?? 0;
          state = TradingAnalyticsServiceState(
              cache: {
            ...state.cache,
            id: PortfolioResult(
              //TODO: fill result's data
            ),
          });
        },
        onError: (error) {
          _incomingSubscription?.cancel();
          _incomingSubscription = null;
          if (error is GrpcError) {
            final errorMsg = _connectionMessage(error);
            log(errorMsg);
            state = TradingAnalyticsServiceState(error: errorMsg, cache: state.cache);
          }
        },
        onDone: () {
          log("gRPC Stream closed");
          _incomingSubscription = null;
        }
      );
    } catch (e) {
      log("Error initializing stream: $e");
    }
  }

  /// Evaluates a specific portfolio strategy based on historical parameters
  Future<void> evaluate(PortfolioConfig portfolio) async {
    if (_outgoingController == null || _outgoingController!.isClosed) {
      _initStream();
    }

    final protoPortfolio = await _toProtoPortfolio(portfolio);

    final request = $pb.EvaluatePortfolioRequest(
      portfolio: protoPortfolio, 
      startDate: $pb_ts.Timestamp.fromDateTime(portfolio.startDateTime),
      endDate: $pb_ts.Timestamp.fromDateTime(portfolio.endDateTime),
      strategyConfig: $pb.StrategyConfig(
        strategyType: _toProtoStrategyType(portfolio.strategy!.type),
        //TODO: fill strategy config
      )
    );
    _outgoingController?.add(request);
  }

  String _connectionMessage(GrpcError grpcError) {
    return switch (grpcError.code) {
      StatusCode.unavailable => "Server is down or unreachable.",
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
      _ => "Unknown connection error: ${grpcError.code}"
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
  
  model_strategy.StrategyType _fromProtoStrategyType($pb.StrategyType type) {
    return switch (type) {
      $pb.StrategyType.EMPTY => model_strategy.StrategyType.empty,
      $pb.StrategyType.ARBITRARY => model_strategy.StrategyType.arbitrary,
      $pb.StrategyType.ASSETALLOCATION => model_strategy.StrategyType.asset,
      $pb.StrategyType.GEM => model_strategy.StrategyType.gem,
      $pb.StrategyType.MEANREVERSION => model_strategy.StrategyType.meanReversion,
      $pb.StrategyType.INDEXFUNDREBALANCING => model_strategy.StrategyType.indexFundRebalancing,
      $pb.StrategyType.TRENDfOLLOWING => model_strategy.StrategyType.trendFollowing,
      _ => model_strategy.StrategyType.empty,     
    };
  }

  $pb_price.IndexPriceItem _toProtoPrice(model_price.IndexPriceItem item) {
    return $pb_price.IndexPriceItem()
      ..id = item.id
      ..assetId = item.assetId
      ..close = item.closePrice
      ..dateTime = $pb_ts.Timestamp.fromDateTime(item.dateTime);
    // skip open, high, low, volume
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
    final priceSchema = model_price.IndexPriceSchema();
    final allocations = portfolio.strategy?.getAssetAllocations() ?? [];

    final protoAllocations = await Future.wait(
      allocations.map((a) async {
        final prices = await ref.read(priceControllerProvider().notifier).fetchDateRange(
            priceSchema, a.asset, portfolio.startDateTime, portfolio.endDateTime);
        return _toProtoAssetAllocation(a, prices);
      }),
    );

    return $pb.Portfolio()
      ..id = portfolio.id.toString()
      ..name = portfolio.portfolioName
      ..description = portfolio.portfolioDesc
      ..initialCapital = portfolio.initialCapital.amount.toDecimal().toDouble()
      ..riskFreeRate = portfolio.riskFreeRatePerYear
      ..allocations.addAll(protoAllocations);
  }
}

/// Provider to watch the result of a specific portfolio evaluation
@riverpod
AsyncValue<PortfolioResult?> portfolioResult(Ref ref, {required String portfolioId}) {
  final id = int.tryParse(portfolioId) ?? 0;
  final (error, result) = ref.watch(tradingAnalyticsServiceProvider.select(
    (s) => (s.error, s.cache[id])
  ));

  if (error != null) return AsyncValue.error(error, StackTrace.current);
  if (result == null) return const AsyncValue.loading();
  
  return AsyncValue.data(result);
}
