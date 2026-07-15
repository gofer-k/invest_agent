// lib/providers/trading_service.dart
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $pb_ts;

// Hide conflicting types from the gRPC generated code to avoid global namespace pollution
import '../model/results/bollinger_bands_result.dart';
import '../model/results/ema_result.dart';
import '../model/results/kst_result.dart';
import '../model/results/macd_result.dart';
import '../model/proto/generated/invest_agent.pbgrpc.dart' hide IndexPriceItem, Indicator, IndicatorType;
import '../model/proto/generated/invest_agent.pb.dart' as $pb;
import '../model/indicator_result.dart';
import '../model/indicator_schema.dart' as schema;
import '../model/results/price_result.dart' as model;
import '../model/results/roc_result.dart';
import '../model/results/rsi_result.dart';
import '../model/results/sma_result.dart';

part 'trading_service.g.dart';

// Unique aliases to ensure the Riverpod generator uses non-conflicting names in .g.dart
typedef InternalIndexPriceItem = model.IndexPriceItem;
typedef InternalIndicator = schema.Indicator;

/// Alias for the generated gRPC client
typedef TradingServiceClient = InvestAgentServiceClient;

// Use 'localhost' as it handles IPv4/IPv6 better on some Linux setups than 127.0.0.1
final String host = String.fromEnvironment(
  'GRPC_HOST', 
  defaultValue: Platform.isAndroid ? '10.0.2.2' : 'localhost'
);

/// Interceptor to log raw gRPC traffic for verification
class GrpcLoggingInterceptor implements ClientInterceptor {
  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method, Stream<Q> requests, CallOptions options, ClientStreamingInvoker<Q, R> invoker) {
    log("gRPC STREAM CALL: ${method.path}");
    return invoker(method, requests.map((q) {
      // log("gRPC SENDING MESSAGE: $q");log("gRPC SENDING MESSAGE: $q");
      log("gRPC SENDING MESSAGE");
      return q;
    }), options);
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request, CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    log("gRPC UNARY CALL: ${method.path} | REQ: $request");
    return invoker(method, request, options);
  }
}

@riverpod
TradingServiceClient tradingClient(Ref ref) {
  final channel = ClientChannel(
    host,
    port: 50051,
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
  return TradingServiceClient(
    channel,
    interceptors: [GrpcLoggingInterceptor()],
  );
}

@immutable
class TradingServiceState {
  final String? error;
  final IndicatorResultMap cache;
  const TradingServiceState({this.cache = const {}, this.error});
}

@riverpod
class TradingService extends _$TradingService {
  late TradingServiceClient _client;
  StreamController<$pb.TradingRequest>? _outgoingController;
  StreamSubscription? _incomingSubscription;

  @override
  TradingServiceState build() {
    _client = ref.watch(tradingClientProvider);
    ref.onDispose(() {
      _incomingSubscription?.cancel();
      _outgoingController?.close();
    });
    return const TradingServiceState(cache: {});
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

  Future<void> _initStream() async {
    if (_incomingSubscription != null) return;
    log("Initializing gRPC bidirectional stream...");
    _outgoingController = StreamController<$pb.TradingRequest>();

    try {
      final responseStream = _client.calculateIndicators(_outgoingController!.stream);
      _incomingSubscription = responseStream.listen((response) {
        log("gRPC Response received with ${response.results.length} results");
        final newResults = _mapResponse(response);
        state = TradingServiceState(cache: {
          ...state.cache,
          ...newResults,
        });
      }, onError: (error) {
        _incomingSubscription?.cancel();
        _incomingSubscription = null;

        if (error is GrpcError) {
          final errorMsg = _connectionMessage(error);
          log(errorMsg);
          state = TradingServiceState(error: errorMsg);
        }
      }, onDone: () {
        log("gRPC Stream closed by server");
        _incomingSubscription = null;
      });
    } catch (e) {
      log("Error initializing stream: $e");
    }
  }

  void calculateIndicators(List<InternalIndexPriceItem> prices, List<InternalIndicator> indicators) {
    // Check for empty list
    if (indicators.isEmpty) {
      log("ABORT: No indicators provided in the list.");
      return;
    }

    // Check for undefined types
    final validIndicators = indicators.where((ind) => ind.type != schema.IndicatorType.undefined).toList();
    if (validIndicators.isEmpty) {
      log("ABORT: All indicators provided have type 'undefined'. Check your Indicator objects.");
      return;
    }

    if (_outgoingController == null || _outgoingController!.isClosed) {
      _initStream();
    }

    final request = $pb.TradingRequest()
      ..prices.addAll(prices.map(_toProtoPrice))
      ..indicators.addAll(validIndicators.map(_toProtoIndicator));

    _outgoingController?.add(request);
  }

  $pb.IndexPriceItem _toProtoPrice(InternalIndexPriceItem item) {
    return $pb.IndexPriceItem()
      ..id = item.id
      ..assetId = item.assetId
      ..open = item.openPrice
      ..high = item.highPrice
      ..low = item.lowPrice
      ..close = item.closePrice
      ..volume = item.volume
      ..dateTime = $pb_ts.Timestamp.fromDateTime(item.dateTime);
  }

  $pb.Indicator _toProtoIndicator(InternalIndicator indicator) {
    final proto = $pb.Indicator()
      ..id = indicator.id
      ..name = indicator.name
      ..type = _toProtoIndicatorType(indicator.type);
    
    if (indicator.parameters.isNotEmpty) {
      proto.ensureParameters().mergeFromProto3Json(indicator.parameters);
    }
    return proto;
  }

  $pb.IndicatorType _toProtoIndicatorType(schema.IndicatorType type) {
    return switch (type) {
      schema.IndicatorType.price => $pb.IndicatorType.PRICE,
      schema.IndicatorType.bollingerBands => $pb.IndicatorType.BOLLINGER_BANDS,
      schema.IndicatorType.sma => $pb.IndicatorType.SMA,
      schema.IndicatorType.ema => $pb.IndicatorType.EMA,
      schema.IndicatorType.macd => $pb.IndicatorType.MACD,
      schema.IndicatorType.rsi => $pb.IndicatorType.RSI,
      schema.IndicatorType.volume => $pb.IndicatorType.VOLUME,
      schema.IndicatorType.kst => $pb.IndicatorType.KST,
      schema.IndicatorType.roc => $pb.IndicatorType.ROC,
      schema.IndicatorType.undefined => $pb.IndicatorType.UNDEFINED,
    };
  }

  IndicatorResultMap _mapResponse($pb.TradingResponse response) {
    final IndicatorResultMap resultMap = {};
    response.results.forEach((key, list) {
      final results = list.items
          .map((series) => _mapSeries(series))
          .whereType<BaseIndicatorResult>()
          .toList();
      for (var result in results) {
        try {
          final indicatorKey = result.config.uniqueKey;
          log("Add result key $indicatorKey, value ${result.config.toDetailedString()}");
          resultMap[indicatorKey] = result;
        }
        catch (e){
          log("Unexpected result key: $key expect ${schema.IndicatorKey}");
        }
      }
    });
    return resultMap;
  }

  BaseIndicatorResult? _mapSeries($pb.IndicatorSeries series) {
    final indicatorType = _fromProtoIndicatorType(series.config.type);
    return switch (indicatorType) {
      schema.IndicatorType.bollingerBands => BollingerBandsResult.fromProto(series, indicatorType),
      schema.IndicatorType.ema => EmaResult.fromProto(series, indicatorType),
      schema.IndicatorType.kst => KstResult.fromProto(series, indicatorType),
      schema.IndicatorType.macd => MacdResult.fromProto(series, indicatorType),
      schema.IndicatorType.roc => RocResult.fromProto(series, indicatorType),
      schema.IndicatorType.rsi => RsiResult.fromProto(series, indicatorType),
      schema.IndicatorType.sma => SmaResult.fromProto(series, indicatorType),
      // schema.IndicatorType.volume => VolumeResult.fromProto(series, indicatorType),
      _ => null,
    };
  }

  schema.IndicatorType _fromProtoIndicatorType($pb.IndicatorType type) {
    return switch (type) {
      $pb.IndicatorType.PRICE => schema.IndicatorType.price,
      $pb.IndicatorType.BOLLINGER_BANDS => schema.IndicatorType.bollingerBands,
      $pb.IndicatorType.SMA => schema.IndicatorType.sma,
      $pb.IndicatorType.EMA => schema.IndicatorType.ema,
      $pb.IndicatorType.MACD => schema.IndicatorType.macd,
      $pb.IndicatorType.RSI => schema.IndicatorType.rsi,
      $pb.IndicatorType.VOLUME => schema.IndicatorType.volume,
      $pb.IndicatorType.KST => schema.IndicatorType.kst,
      $pb.IndicatorType.ROC => schema.IndicatorType.roc,
      _ => schema.IndicatorType.undefined,
    };
  }

  void clearResults() => state = const TradingServiceState();

  void removeResult(InternalIndicator indicator) {
    state.cache.remove(indicator.uniqueKey);
  }

  double? getMax(schema.Indicator indicator, {DateTime? startDate, DateTime? endDate}) {
    final res = state.cache[indicator.uniqueKey];
    return res?.getMax(startDate, endDate) ?? 0.0;
  }

  double? getMin(schema.Indicator indicator, {DateTime? startDate, DateTime? endDate}) {
    final res = state.cache[indicator.uniqueKey];
    return res?.getMin(startDate, endDate) ?? 0.0;
  }
}

@riverpod
AsyncValue<IndicatorResult?> indicatorResult(Ref ref,
  {required List<InternalIndexPriceItem> prices,
   required InternalIndicator indicator}) {
  
  if (indicator.type == schema.IndicatorType.undefined) {
    return const AsyncValue.data(null);
  }
  log("IndicatorResult: Requesting indicator result for ${indicator.uniqueKey} value ${indicator.toDetailedString()}");
  final cache = ref.watch(tradingServiceProvider.select((s) => s.cache[indicator.uniqueKey]));

  if (cache == null) {
    log("IndicatorResult: No cache for ${indicator.uniqueKey}. Requesting calculation...");
    Future.microtask(() {
      ref.read(tradingServiceProvider.notifier).calculateIndicators(prices, [indicator]);
    });
    return const AsyncValue.loading();
  }
  log("IndicatorResult: Response found in cache for ${cache.config.uniqueKey}");
  return AsyncValue.data(cache);
}
