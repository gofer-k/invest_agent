import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/model/results/indicator/price_result.dart';
import 'package:invest_agent/model/results/strategies/mean_reversion.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart' as model_strategy;
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/trading_analytics_service.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:invest_agent/model/proto/generated/portfolio.pb.dart' as $pb;
import 'package:invest_agent/model/proto/generated/portfolio.pbgrpc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $ts;

// Run 'flutter pub run build_runner build' to generate this file
import 'trading_analytics_service_test.mocks.dart';

@GenerateMocks([AnalyticsServiceClient])
void main() {
  setUpAll(() {
    try {
      final ldPath = Platform.environment['DUCKDB_PATH'];
      bool loaded = false;
      if (ldPath != null) {
        for (final path in ldPath.split(':')) {
          final file = File('$path/libduckdb.so');
          if (file.existsSync()) {
            DynamicLibrary.open(file.path);
            loaded = true;
            break;
          }
        }
      }
      if (!loaded) {
        final homePath = Platform.environment['HOME'];
        try {
          DynamicLibrary.open('$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so');
        } catch (_) {}
      }
    } catch (e) {
      dev.log('Library load info: $e');
    }
  });

  late MockAnalyticsServiceClient mockClient;
  late ProviderContainer container;
  late DatabaseHelper dbHelper;

  setUp(() async {
    mockClient = MockAnalyticsServiceClient();
    
    // Setup a real DatabaseHelper with memory storage for PriceController
    // Mocking the Notifier class directly often leads to Riverpod internal errors (_element not found)
    dbHelper = DatabaseHelper(cacheFile: CacheKeyType.memoryCache.key);
    await dbHelper.init();
    await dbHelper.createCache(AssetConfigSchema());
    await dbHelper.createCache(IndexPriceSchema());

    container = ProviderContainer(
      overrides: [
        tradingAnalyticsClientProvider().overrideWith((ref) => mockClient),
        // Override the database provider used by the real PriceController
        loadPriceProvider(null, false).overrideWith((ref) => dbHelper),
        loadPriceProvider(null, true).overrideWith((ref) => dbHelper),
      ],
    );
  });

  tearDown(() async {
    dbHelper.dispose();
    container.dispose();
  });

  group('TradingAnalyticsService Tests', () {
    test('Initial state should have empty cache', () {
      final state = container.read(tradingAnalyticsServiceProvider);
      expect(state.cache, isEmpty);
      expect(state.error, isNull);
    });

    test('evaluate should send correct request and update state on response', () async {
      final portfolio = PortfolioConfig(
        id: 1,
        portfolioName: 'Test Portfolio',
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2023, 12, 31),
        strategy: MeanReversionConfig.fromStrategy(
          model_strategy.Strategy(
            type: model_strategy.StrategyType.meanReversion,
            id: model_strategy.Strategy.defaultId,
            name: 'Mean Reversion'),
        )
      );

      // Mock AnalyticsServiceClient.evaluatePortfolio response
      final response = $pb.EvaluatePortfolioResponse()
        ..portfolioId = '1'
        ..calculatedAt = $ts.Timestamp.fromDateTime(DateTime.now())
        ..summaryMetrics = ($pb.PerformanceMetrics()
          ..totalReturn = 0.15
          ..annualizedReturn = 0.12
          ..sharpeRatio = 1.5)
        ..equityCurve.add($pb.EquityCurvePoint()
          ..timestamp = $ts.Timestamp.fromDateTime(DateTime(2023, 1, 1))
          ..portfolioValue = 10000.0
          ..drawdown = 0.0);

      final responseFuture = _FakeResponseFuture.value(response);
      when(mockClient.evaluatePortfolio(any, options: anyNamed('options')))
          .thenAnswer((_) => responseFuture);

      final notifier = container.read(tradingAnalyticsServiceProvider.notifier);
      
      // Keep provider alive so it doesn't auto-dispose
      container.listen(tradingAnalyticsServiceProvider, (prev, next) {});

      await notifier.evaluate(portfolio);

      // Wait for async operations (PriceController fetching prices + gRPC response processing)
      await pumpEventQueue();

      final state = container.read(tradingAnalyticsServiceProvider);
      expect(state.cache.containsKey(1), isTrue);
      
      final result = state.cache[1]!;
      expect(result.performanceMetrics.totalReturn, 0.15);
      expect(result.performanceMetrics.sharpeRatio, 1.5);
      expect(result.equityCurve.length, 1);
      expect(result.equityCurve.first.portfolioValue, 10000.0);
    });

    test('evaluate should handle GrpcError and update state with error message', () async {
      final portfolio = PortfolioConfig(
        id: 2,
        portfolioName: 'Error Portfolio',
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2023, 12, 31),
        strategy: MeanReversionConfig.fromStrategy(
          model_strategy.Strategy(
              type: model_strategy.StrategyType.meanReversion,
              id: model_strategy.Strategy.defaultId,
              name: 'Mean Reversion'),
        )
      );

      final grpcError = GrpcError.unavailable('Server is down');
      
      // Use a completer to trigger the error after the service starts listening
      final completer = Completer<$pb.EvaluatePortfolioResponse>();
      final responseFuture = _FakeResponseFuture(completer.future);
      
      when(mockClient.evaluatePortfolio(any, options: anyNamed('options')))
          .thenAnswer((_) => responseFuture);

      final notifier = container.read(tradingAnalyticsServiceProvider.notifier);
      container.listen(tradingAnalyticsServiceProvider, (prev, next) {});

      await notifier.evaluate(portfolio);
      
      // Trigger the error. We use try-catch or catchError to prevent the test runner 
      // from seeing this as an unhandled exception before the service catches it.
      completer.completeError(grpcError);
      await completer.future.catchError((_) => $pb.EvaluatePortfolioResponse());

      await pumpEventQueue();

      final state = container.read(tradingAnalyticsServiceProvider);
      expect(state.error, contains('Server is down or unreachable'));
    });
  });
}

/// A robust fake ResponseFuture implementation for testing gRPC unary calls.
class _FakeResponseFuture<T> extends Fake implements ResponseFuture<T> {
  final Future<T> _future;

  _FakeResponseFuture(this._future);

  factory _FakeResponseFuture.value(T value) =>
      _FakeResponseFuture(Future.value(value));

  @override
  Future<S> then<S>(FutureOr<S> Function(T) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
      
  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);
      
  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<void> cancel() async {}
}
