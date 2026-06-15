// lib/providers/trading_service.dart
import 'dart:async';
import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $pb_wkt;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $pb_wkt;
import 'package:collection/collection.dart';

import '../model/proto/generated/invest_agent.pbgrpc.dart' hide IndexPriceItem;
import '../model/proto/generated/invest_agent.pb.dart' as $pb;
import '../model/indicator_result.dart';
import '../model/price_result.dart';
import '../model/indicator_schema.dart' as schema;

part 'trading_service.g.dart';

/// Alias for the generated gRPC client
typedef TradingServiceClient = InvestAgentServiceClient;

@riverpod
class TradingService extends _$TradingService {
  late ClientChannel _channel;
  late TradingServiceClient _client;

  StreamController<$pb.TradingRequest>? _outgoingController;
  StreamSubscription? _incomingSubscription;

  @override
  IndicatorResultMap build() {
    // Initialize gRPC channel
    _channel = ClientChannel(
      'invest-agent-service',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _client = TradingServiceClient(_channel);

    ref.onDispose(() {
      _incomingSubscription?.cancel();
      _outgoingController?.close();
      _channel.shutdown();
    });

    return {};
  }

  /// Establishes the bidirectional stream
  Future<void> _initStream() async {
    if (_incomingSubscription != null) return;

    _outgoingController = StreamController<$pb.TradingRequest>();

    final responseStream = _client.calculateIndicators(_outgoingController!.stream);

    _incomingSubscription = responseStream.listen((response) {
      state = _mapResponse(response);
    }, onError: (error) {
      log("Failed remote respond call: $error ");
    });
  }

  /// Sends prices and indicators to the service for calculation
  void calculateIndicators(List<IndexPriceItem> prices, List<schema.Indicator> indicators) {
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

  $pb.IndexPriceItem _toProtoPrice(IndexPriceItem item) {
    return $pb.IndexPriceItem()
      ..id = item.id
      ..assetId = item.assetId
      ..open = item.openPrice
      ..high = item.highPrice
      ..low = item.lowPrice
      ..close = item.closePrice
      ..volume = item.volume
      ..dateTime = $pb_wkt.Timestamp.fromDateTime(item.dateTime);
  }

  $pb.Indicator _toProtoIndicator(schema.Indicator indicator) {
    return $pb.Indicator()
      ..id = indicator.id
      ..name = indicator.name
      ..type = _toProtoIndicatorType(indicator.type)
      ..parameters = $pb_wkt.Struct.create()..mergeFromProto3Json(indicator.parameters);
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
            (e) => e.name == key || e.name.toUpperCase() == key.toUpperCase(),
      ) ?? schema.IndicatorType.undefined;

      // Skip non-SMA values as requested
      if (type != schema.IndicatorType.sma) return;

      final results = list.items
          .map((series) => _mapSeries(series)).nonNulls.toList();
      
      if (results.isNotEmpty) {
        resultMap[type] = results;
      }
    });
    return resultMap;
  }

  BaseIndicatorResult? _mapSeries($pb.IndicatorSeries series) {
    final indicatorType = _fromProtoIndicatorType(series.config.type);
    
    // Only handle SMA and skip others as requested
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
    state = {};
  }
}
