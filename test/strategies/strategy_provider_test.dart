import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/results/strategies/global_equity_momentum.dart';
import 'package:invest_agent/model/results/strategies/mean_reversion.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:invest_agent/providers/strategy_provider.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';

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
        DynamicLibrary.open('$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so');
      }
    } catch (e) {
      // Ignored
    }
  });

  group('StrategyProvider Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final schema = StrategySchema();
    const testPath = CacheKeyType.memoryCache;
    // final AssetConfig asset = AssetConfig.defaultAsset();

    // Mock Data
    final gemStrategy = GemStrategyConfig.emptyStrategy().copyWith(
      newId: 1,
      newName: 'Test GEM Strategy',
    ) as GemStrategyConfig;

    // Replace with actual MeanReversionConfig implementation
    final mrStrategy = MeanReversionConfig.emptyStrategy().copyWith(
      newId: 2,
      newName: 'Test Mean Reversion',
    );

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: testPath.key);
      await dbHelper.init();
      await dbHelper.createCache(schema);

      container = ProviderContainer(
        overrides: [
        ],
      );
      container.listen(strategyProvider(testPath), (_,_){});
    });

    tearDown(() {
      container.dispose();
      dbHelper.dispose();
    });

    test('Initial state should be empty', () {
      final state = container.read(strategyProvider());
      expect(state.cachedStrategies, isEmpty);
    });

    test('addEntry adds a Gem strategy a updates the state', () async {
      await container.read(loadDatabaseProvider(testPath).future);

      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(gemStrategy);

      final state = container.read(strategyProvider(testPath));
      expect(state.cachedStrategies.length, 1);
      expect(state.cachedStrategies.first.id, gemStrategy.id);
      expect(state.cachedStrategies.first.type, StrategyType.gem);
    });

    test('addEntry adds a mean reversion strategy a updates the state', () async {
      await container.read(loadDatabaseProvider(testPath).future);

      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(mrStrategy);

      final state = container.read(strategyProvider(testPath));
      expect(state.cachedStrategies.length, 1);
      expect(state.cachedStrategies.first.id, gemStrategy.id);
      expect(state.cachedStrategies.first.type, StrategyType.meanReversion);
    });

    test('updateEntry updates a strategy in the database', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(gemStrategy);
      await notifier.addEntry(mrStrategy);
      final state = container.read(strategyProvider(testPath));
      expect(state.cachedStrategies.length, 2);
      expect(state.cachedStrategies.first.id, gemStrategy.id);
      expect(state.cachedStrategies.first.type, StrategyType.gem);
      expect(state.cachedStrategies.last.id, mrStrategy.id);
      expect(state.cachedStrategies.last.type, StrategyType.meanReversion);
      final getName = 'Updated GEM Strategy';
      await notifier.updateEntry(gemStrategy.copyWith(newName: getName) as GemStrategyConfig);
      final updatedState = container.read(strategyProvider(testPath));
      expect(updatedState.cachedStrategies.length, 2);
      final updatedGem = updatedState.cachedStrategies.firstWhere((s) => s.id == gemStrategy.id);
      expect(updatedGem.id, gemStrategy.id);
      expect(updatedGem.type, StrategyType.gem);
      expect(updatedGem.name, getName);
    });

    test('deleteEntry deletes a strategy from the database', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(gemStrategy);
      await notifier.addEntry(mrStrategy);
      final state = container.read(strategyProvider(testPath));
      expect(state.cachedStrategies.length, 2);
      expect(state.cachedStrategies.first.id, gemStrategy.id);

      await notifier.deleteEntry(gemStrategy);
      final updatedState = container.read(strategyProvider(testPath));
      expect(updatedState.cachedStrategies.length, 1);
      expect(updatedState.cachedStrategies.first.id, mrStrategy.id);
      expect(updatedState.cachedStrategies.first.type, StrategyType.meanReversion);
    });

    test('clearAll deletes all strategies from the database', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(gemStrategy);
      await notifier.addEntry(mrStrategy);
      final state = container.read(strategyProvider(testPath));
      expect(state.cachedStrategies.length, 2);
      await notifier.clearAll();
      final updatedState = container.read(strategyProvider(testPath));
      expect(updatedState.cachedStrategies.length, 0);
    });
  });
}
