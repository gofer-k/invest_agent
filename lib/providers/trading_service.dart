// lib/providers/trading_service.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $pb_ts;
import 'package:collection/collection.dart';

// Hide conflicting types from the gRPC generated code to avoid global namespace pollution
import '../model/proto/generated/invest_agent.pbgrpc.dart' hide IndexPriceItem, Indicator, IndicatorType;
import '../model/proto/generated/invest_agent.pb.dart' as $pb;
import '../model/indicator_result.dart';
import '../model/indicator_schema.dart' as schema;
import '../model/price_result.dart' as model;

part 'trading_service.g.dart';

// Unique aliases to ensure the Riverpod generator uses non-conflicting names in .g.dart
typedef InternalIndexPriceItem = model.IndexPriceItem;
typedef InternalIndicator = schema.Indicator;

/// Alias for the generated gRPC client
typedef TradingServiceClient = InvestAgentServiceClient;

@riverpod
TradingServiceClient tradingClient(Ref ref) {
  final channel = ClientChannel(
    'invest-agent-service',
    port: 50051,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  ref.onDispose(() => channel.shutdown());
  return TradingServiceClient(channel);
}

@immutable
class TradingServiceState {
  final IndicatorResultMap cache;

  const TradingServiceState({this.cache = const {}});

  TradingServiceState copyWith({IndicatorResultMap? results}) {
    return TradingServiceState(cache: results ?? cache);
  }
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

  /// Establishes the bidirectional stream
  Future<void> _initStream() async {
    if (_incomingSubscription != null) return;

    _outgoingController = StreamController<$pb.TradingRequest>();

    final responseStream = _client.calculateIndicators(_outgoingController!.stream);

    _incomingSubscription = responseStream.listen((response) {
     final results = _mapResponse(response);
     state = TradingServiceState(cache: results);
    }, onError: (error) {
      log("Failed remote respond call: $error ");
    });
  }

  /// Sends prices and indicators to the service for calculation
  void calculateIndicators(List<InternalIndexPriceItem> prices, List<InternalIndicator> indicators) {
    if (indicators.every((ind) => ind.type == schema.IndicatorType.undefined)) return;

    if (_outgoingController == null || _outgoingController!.isClosed) {
      _initStream();
    }

    final request = $pb.TradingRequest()
      ..prices.addAll(prices.map(_toProtoPrice))
      ..indicators.addAll(indicators.map(_toProtoIndicator));

    _outgoingController?.add(request);
  }

  // --- Mappers: Internal to Proto ---

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
      // Use ensureParameters() to get a mutable Struct instance.
      // Modifying the field directly via getter returns a read-only default instance.
      proto.ensureParameters().mergeFromProto3Json(indicator.parameters);
    }
    return proto;
  }

  $pb.IndicatorType _toProtoIndicatorType(schema.IndicatorType type) {
    return switch (type) {
      schema.IndicatorType.price => $pb.IndicatorType.PRICE,
      schema.IndicatorType.bellingerBands => $pb.IndicatorType.BOLLINGER_BANDS,
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

  // --- Mappers: Proto to Internal ---

  IndicatorResultMap _mapResponse($pb.TradingResponse response) {
    final IndicatorResultMap resultMap = {};
    response.results.forEach((key, list) {
      final type = schema.IndicatorType.values.firstWhereOrNull(
        (e) => e.name.toUpperCase() == key.toUpperCase() || e.shortName.toUpperCase() == key.toUpperCase(),
      ) ?? schema.IndicatorType.undefined;

      // Only handle SMA for now as per previous requirement
      if (type != schema.IndicatorType.sma) return;

      final results = list.items
          .map((series) => _mapSeries(series))
          .whereType<BaseIndicatorResult>()
          .toList();
      
      if (results.isNotEmpty) {
        resultMap[type] = results;
      }
    });
    return resultMap;
  }

  BaseIndicatorResult? _mapSeries($pb.IndicatorSeries series) {
    final indicatorType = _fromProtoIndicatorType(series.config.type);
    
    if (indicatorType != schema.IndicatorType.sma) {
      return null;
    }

    return SmaResult.fromProto(series, indicatorType);
  }

  schema.IndicatorType _fromProtoIndicatorType($pb.IndicatorType type) {
    return switch (type) {
      $pb.IndicatorType.PRICE => schema.IndicatorType.price,
      $pb.IndicatorType.BOLLINGER_BANDS => schema.IndicatorType.bellingerBands,
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

  void clearResults() {
    state = const TradingServiceState();
  }

  double? getMax(schema.IndicatorType indicatorType, {DateTime? startDate, DateTime? endDate}) {
    final results = state.cache[indicatorType];
    if (results == null || results.isEmpty) return null;

    return results
        .map((res) => res.getMax(startDate, endDate))
        .reduce((a, b) => a > b ? a : b);
  }

  double? getMin(schema.IndicatorType indicatorType, {DateTime? startDate, DateTime? endDate}) {
    final results = state.cache[indicatorType];
    if (results == null || results.isEmpty) return null;

    return results
        .map((res) => res.getMin(startDate, endDate))
        .reduce((a, b) => a < b ? a : b);
  }
}

@riverpod
AsyncValue<IndicatorResult> indicatorResult(Ref ref,
  {required List<InternalIndexPriceItem> prices,
   required InternalIndicator indicator}) {
  // Watch the cache in the TradingService state
  final cache = ref.watch(tradingServiceProvider.select((s) => s.cache[indicator.type]));

  if (cache == null) {
    // If not in cache, trigger calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradingServiceProvider.notifier).calculateIndicators(prices, [indicator]);
    });
    return const AsyncValue.loading();
  }

  return AsyncValue.data(cache);
}
