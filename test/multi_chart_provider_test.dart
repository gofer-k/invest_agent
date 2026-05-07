import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/multi_chart_provider.dart';
import 'package:invest_agent/providers/cache_notifier.dart';
import 'package:test/test.dart';

import 'package:invest_agent/utils/database_helper.dart';

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

  group('MultiChartNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final schema = MultiChartConfigSchema();
    const testPath = ':memory:';

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: testPath);
      await dbHelper.init();
      // MultiChartConfigSchema needs a sequence
      await dbHelper.execute(schema.createKey);
      await dbHelper.createCache(schema);
      await dbHelper.deleteAll(schema);

      container = ProviderContainer(
        overrides: [
          loadDatabaseProvider(CacheKeyType.analysisCache).overrideWith((ref) => Future.value(testPath)),
          appCacheHelperProvider(testPath, schema).overrideWith((ref) => Future.value(dbHelper)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      dbHelper.dispose();
    });

    test('Initial state is empty', () async {
      await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
      
      final state = container.read(multiChartNotifierProvider());
      expect(state.cache, isEmpty);
    });

    test('addEntry adds a chart and updates state', () async {
      await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
      
      final config = MultiChartConfig(id: 1, title: 'Test Chart');
      
      final notifier = container.read(multiChartNotifierProvider().notifier);
      await notifier.addEntry(config);
      
      final state = container.read(multiChartNotifierProvider());
      expect(state.cache.length, 1);
      expect(state.cache.first.title, 'Test Chart');
    });

    test('updateMultiChart updates a chart', () async {
       await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart');
       await container.read(multiChartNotifierProvider().notifier).addEntry(config);
       
       var state = container.read(multiChartNotifierProvider());
       final added = state.cache.first;
       
       final updatedConfig = added.copyWith(null, 'Updated Chart', null);
       await container.read(multiChartNotifierProvider().notifier).updateMultiChart(updatedConfig);
       
       state = container.read(multiChartNotifierProvider());
       expect(state.cache.first.title, 'Updated Chart');
    });

    test('deleteEntry removes a chart', () async {
       await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart');
       await container.read(multiChartNotifierProvider().notifier).addEntry(config);
       
       var state = container.read(multiChartNotifierProvider());
       expect(state.cache.length, 1);
       
       await container.read(multiChartNotifierProvider().notifier).deleteEntry(state.cache.first);
       
       state = container.read(multiChartNotifierProvider());
       expect(state.cache, isEmpty);
    });

    test('clearAll removes all charts', () async {
       await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
       
       final notifier = container.read(multiChartNotifierProvider().notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'A'));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'B'));
       
       expect(container.read(multiChartNotifierProvider()).cache.length, 2);
       
       await notifier.clearAll();
       
       expect(container.read(multiChartNotifierProvider()).cache, isEmpty);
    });

    test('sortedMultiCharts returns sorted list', () async {
       await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
       
       final notifier = container.read(multiChartNotifierProvider().notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'C'));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'A'));
       await notifier.addEntry(MultiChartConfig(id: 3, title: 'B'));
       
       final sorted = container.read(sortedMultiChartsProvider);
       expect(sorted.map((e) => e.title).toList(), ['A', 'B', 'C']);
    });

    test('build handles error in loadDatabaseProvider', () async {
      final errorContainer = ProviderContainer(
        overrides: [
          loadDatabaseProvider(CacheKeyType.analysisCache).overrideWith((ref) => Future.error('DB error')),
        ],
      );
      
      final state = errorContainer.read(multiChartNotifierProvider());
      expect(state.cache, isEmpty);
      expect(errorContainer.read(multiChartNotifierProvider().notifier).dbPath, isEmpty);
    });
  });
}
