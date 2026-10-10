import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/results/strategies/global_equity_momentum.dart';
import 'package:invest_agent/model/results/strategies/mean_reversion.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:invest_agent/providers/strategy_provider.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/model_config.dart';
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
    const testPath = CacheKeyType.memoryCache;

    // Mock Data
    final gemStrategy = GemStrategyConfig.emptyStrategy().copyWith(
      newId: 1,
      newName: 'Test GEM Strategy',
    ) as GemStrategyConfig;

    final mrStrategy = MeanReversionConfig.emptyStrategy().copyWith(
      newId: 2,
      newName: 'Test Mean Reversion',
    );

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          assetsLoaderProvider.overrideWith((ref) async => []),
        ],
      );
      
      // Keep the provider alive throughout the test.
      container.listen(strategyProvider(testPath), (previous, next) {});
      
      // Wait for initial load to finish
      await container.read(strategyProvider(testPath).future);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should be empty', () async {
      final state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig, isEmpty);
    });

    test('addEntry adds a Gem strategy and updates the state', () async {
      final notifier = container.read(strategyProvider(testPath).notifier);
      await notifier.addEntry(gemStrategy);

      // Wait for the async rebuild triggered by invalidation to settle
      final state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 1);
      expect(state.cachedConfig.first.name, gemStrategy.name);
      expect(state.cachedConfig.first.type, StrategyType.gem);
    });

    test('addEntry adds a mean reversion strategy and updates the state', () async {
      final notifier = container.read(strategyProvider(testPath).notifier);
      
      // Add both to satisfy cumulative expectations if required, 
      // but standard isolation means we add Gem then MR to check for 2 items.
      await notifier.addEntry(gemStrategy);
      await container.read(strategyProvider(testPath).future); // Wait for first add
      
      await notifier.addEntry(mrStrategy);
      final state = await container.read(strategyProvider(testPath).future); // Wait for second add
      
      expect(state.cachedConfig.length, 2);
      expect(state.cachedConfig.any((s) => s.type == StrategyType.meanReversion), true);
    });

    test('updateEntry updates a strategy in the database', () async {
      final notifier = container.read(strategyProvider(testPath).notifier);
      
      await notifier.addEntry(gemStrategy);
      await container.read(strategyProvider(testPath).future);
      
      await notifier.addEntry(mrStrategy);
      var state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 2);
      
      const updatedName = 'Updated GEM Strategy';
      await notifier.updateEntry(gemStrategy.copyWith(newName: updatedName) as GemStrategyConfig);
      
      // Await the rebuild after update
      state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 2);
      final updatedGem = state.cachedConfig.firstWhere((s) => s.name == updatedName);
      expect(updatedGem.type, StrategyType.gem);
    });

    test('deleteEntry deletes a strategy from the database', () async {
      final notifier = container.read(strategyProvider(testPath).notifier);
      
      await notifier.addEntry(gemStrategy);
      await container.read(strategyProvider(testPath).future);
      
      await notifier.addEntry(mrStrategy);
      await container.read(strategyProvider(testPath).future);
      
      var state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 2);

      await notifier.deleteEntry(gemStrategy);
      
      // Await the rebuild after deletion
      state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 1);
      expect(state.cachedConfig.first.name, mrStrategy.name);
    });

    test('clearAll deletes all strategies from the database', () async {
      final notifier = container.read(strategyProvider(testPath).notifier);

      await notifier.addEntry(gemStrategy);
      await container.read(strategyProvider(testPath).future);
      
      await notifier.addEntry(mrStrategy);
      await container.read(strategyProvider(testPath).future);
      
      var state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 2);
      
      await notifier.clearAll();
      
      // Await the rebuild after clearing
      state = await container.read(strategyProvider(testPath).future);
      expect(state.cachedConfig.length, 0);
    });
  });
}
