import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/providers/indicator_provider.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:test/test.dart';

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
      // Ignored for environments where duckdb might not be available
    }
  });

  group('IndicatorNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    const testPath = CacheKeyType.memoryCache;

    setUp(() async {
      // Get the singleton instance pointing to in-memory for testing
      dbHelper = DatabaseHelper(cacheFile: testPath.key);
      await dbHelper.init();

      const schema = IndicatorSchema();
      await dbHelper.createCache(schema);
      container = ProviderContainer(
        overrides: [
        ],
      );
      container.listen(indicatorProvider(testPath), (_,_){});
    });

    tearDown(() {
      container.dispose();
      // We don't necessarily want to dispose the singleton dbHelper here
      // if it's being reused, but deleteAll handles the state isolation.
      dbHelper.dispose();
    });

    test('Initial state is empty list', () async {
      final state = container.read(indicatorProvider(testPath));
      expect(state.cache, []);
    });

    test('addIndicator adds an indicator and updates state', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0,
        name: 'SMA 20',
        type: IndicatorType.sma,
        parameters: {'window': 20},
      ));

      final state = container.read(indicatorProvider(testPath));
      expect(state.cache.length, 1);
      expect((state.cache.first).name, 'SMA 20');
    });

    test('updateIndicator modifies existing indicator', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      container.read(indicatorProvider(testPath));
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0, name: 'Old', type: IndicatorType.sma, parameters: {},
      ));

      var state = container.read(indicatorProvider(testPath));
      final savedIndicator = state.cache.first;

      await notifier.updateIndicator(Indicator(
        id: savedIndicator.id,
        name: 'New',
        type: IndicatorType.sma,
        parameters: {'p': [1]},
      ));

      final newState = container.read(indicatorProvider(testPath));
      final savedNewIndicator = newState.cache.first;
      expect(savedNewIndicator.name, 'New');
    });

    test('deleteIndicator removes an indicator', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      container.read(indicatorProvider(testPath));
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0, name: 'T1', type: IndicatorType.undefined, parameters: {},
      ));

      var state = container.read(indicatorProvider(testPath));
      expect(state.cache.length, 1);

      await notifier.deleteEntry(state.cache.first);

      state = await container.read(indicatorProvider(testPath));
      expect(state.cache, isEmpty);
    });
  });
}
