import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:invest_agent/providers/trading_service.dart';
import 'package:invest_agent/model/proto/generated/invest_agent.pbgrpc.dart' hide IndexPriceItem;
import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' as $pb;
import 'package:invest_agent/model/price_result.dart';
import 'package:invest_agent/model/indicator_schema.dart' as schema;
import 'package:invest_agent/model/indicator_result.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $ts;

// Run 'flutter pub run build_runner build' to generate this file
import 'trading_service_test.mocks.dart';

@GenerateMocks([InvestAgentServiceClient, ResponseStream])
void main() {
  late MockInvestAgentServiceClient mockClient;
  late MockResponseStream<$pb.TradingResponse> mockResponseStream;
  late StreamController<$pb.TradingResponse> responseController;
  late ProviderContainer container;

  setUp(() {
    mockClient = MockInvestAgentServiceClient();
    mockResponseStream = MockResponseStream<$pb.TradingResponse>();
    responseController = StreamController<$pb.TradingResponse>();

    // Mock the listen method of the response stream to use our controller
    when(mockResponseStream.listen(
      any,
      onError: anyNamed('onError'),
      onDone: anyNamed('onDone'),
      cancelOnError: anyNamed('cancelOnError'),
    )).thenAnswer((invocation) {
      return responseController.stream.listen(
        invocation.positionalArguments[0],
        onError: invocation.namedArguments[#onError],
        onDone: invocation.namedArguments[#onDone],
        cancelOnError: invocation.namedArguments[#cancelOnError],
      );
    });

    // Mock calculateIndicators call to return our mock stream
    when(mockClient.calculateIndicators(any, options: anyNamed('options')))
        .thenAnswer((_) => mockResponseStream);

    container = ProviderContainer(
      overrides: [
        tradingClientProvider.overrideWith((ref) => mockClient),
      ],
    );
  });

  tearDown(() {
    responseController.close();
    container.dispose();
  });

  group('TradingService Tests', () {
    test('Initial state should have empty cache', () {
      final state = container.read(tradingServiceProvider);
      expect(state.cache, isEmpty);
    });

    test('calculateIndicators should establish stream and send correctly mapped request', () async {
      final prices = [
        IndexPriceItem(
          id: 1,
          assetId: 10,
          openPrice: 100,
          highPrice: 110,
          lowPrice: 90,
          closePrice: 105,
          volume: 1000,
          dateTime: DateTime(2023, 1, 1),
        ),
      ];
      final indicators = [
        schema.Indicator(
          id: 1,
          name: 'SMA 20',
          type: schema.IndicatorType.sma,
          parameters: {'window': 20},
        ),
      ];

      final notifier = container.read(tradingServiceProvider.notifier);
      notifier.calculateIndicators(prices, indicators);

      // Verify calculateIndicators was called on gRPC client
      final captured = verify(mockClient.calculateIndicators(captureAny, options: anyNamed('options'))).captured;
      final requestStream = captured.first as Stream<$pb.TradingRequest>;

      // Check the first request emitted to the stream
      final request = await requestStream.first;
      expect(request.prices, hasLength(1));
      expect(request.prices.first.assetId, 10);
      expect(request.prices.first.close, 105.0);
      expect(request.indicators, hasLength(1));
      expect(request.indicators.first.name, 'SMA 20');
      expect(request.indicators.first.type, $pb.IndicatorType.SMA);
    });

    test('state should update when stream receives TradingResponse with SMA data', () async {
      // Keep provider alive so it doesn't auto-dispose during async operations
      final subscription = container.listen(tradingServiceProvider, (prev, next) {});

      final requestIndicator = schema.Indicator(id: 1, name: 'T', type: schema.IndicatorType.sma, parameters: {});

      // Initialize stream
      container.read(tradingServiceProvider.notifier).calculateIndicators([], [
        requestIndicator
      ]);

      // Simulate a server response
      final response = $pb.TradingResponse();
      final series = $pb.IndicatorSeries()
        ..chartStyle = 'line'
        ..config = ($pb.Indicator()
          ..id = 1
          ..name = 'SMA 20'
          ..type = $pb.IndicatorType.SMA);
      
      series.config.ensureParameters().mergeFromProto3Json({'window': 20});

      series.points.add($pb.IndicatorPoint()
        ..dateTime = $ts.Timestamp.fromDateTime(DateTime(2023, 1, 1))
        ..values.addAll({'mean': 102.5, 'std': 2.0}));
      
      // Use standard name (e.g. "SMA") to ensure matching in _mapResponse
      response.results[$pb.IndicatorType.SMA.name] = $pb.IndicatorResultList()..items.add(series);

      // Send response through the controller
      responseController.add(response);

      // Allow enough time for all async stream and state updates
      await pumpEventQueue();

      final state = container.read(tradingServiceProvider);
      expect(state.cache.isNotEmpty, true, reason: 'Cache should not be empty after receiving data');
      expect(state.cache.containsKey(requestIndicator.uniqueKey), isTrue);

      final result = state.cache[requestIndicator.uniqueKey]!;
      expect(result, isA<SmaResult>());

      final smaResult = result as SmaResult;
      expect(smaResult.points.first.rollingMean, 102.5);
      
      subscription.close();
    });

    test('clearResults should reset cache to empty', () async {
      container.read(tradingServiceProvider.notifier).clearResults();
      final state = container.read(tradingServiceProvider);
      expect(state.cache, isEmpty);
    });

    test('getMax should calculate highest value across series in cache', () async {
      // Keep provider alive
      final subscription = container.listen(tradingServiceProvider, (prev, next) {});
      final requestIndicator = schema.Indicator(id: 1, name: 'T', type: schema.IndicatorType.sma, parameters: {});
       // Initialize with mock data by pushing to stream
      container.read(tradingServiceProvider.notifier).calculateIndicators([], [
        requestIndicator
      ]);

      final response = $pb.TradingResponse();
      final series = $pb.IndicatorSeries()
        ..chartStyle = 'line'
        ..config = ($pb.Indicator()..type = $pb.IndicatorType.SMA)
        ..points.addAll([
          $pb.IndicatorPoint()
            ..dateTime = $ts.Timestamp.fromDateTime(DateTime(2023, 1, 1))
            ..values.addAll({'mean': 100.0}),
          $pb.IndicatorPoint()
            ..dateTime = $ts.Timestamp.fromDateTime(DateTime(2023, 1, 2))
            ..values.addAll({'mean': 150.0}),
        ]);
      
      // Use "SMA" key which matches toString() of IndicatorType.sma
      response.results[schema.IndicatorType.sma.toString()] = $pb.IndicatorResultList()..items.add(series);
      responseController.add(response);

      await pumpEventQueue();

      final notifier = container.read(tradingServiceProvider.notifier);
      expect(notifier.getMax(requestIndicator), 150.0);

      subscription.close();
    });
  });
}
