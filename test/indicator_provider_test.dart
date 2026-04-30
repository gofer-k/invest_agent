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
    const testPath = ':memory:';

    setUp(() async {
      // Get the singleton instance pointing to in-memory for testing
      dbHelper = DatabaseHelper(testPath);
      await dbHelper.init();

      const schema = IndicatorSchema();
      // Clear the database state before each test to ensure isolation
      await dbHelper.createCache(schema);
      await dbHelper.deleteAll(schema);

      container = ProviderContainer(
        overrides: [
          // Must match the path and schema used in IndicatorNotifier
          appCacheHelperProvider(testPath, schema).overrideWith((ref) => dbHelper),
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
      final state = await container.read(indicatorProvider(testPath).future);
      expect(state, isEmpty);
    });

    test('addIndicator adds an indicator and updates state', () async {
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0,
        name: 'SMA 20',
        type: 'SMA',
        parameters: {'window': 20},
      ));

      final state = await container.read(indicatorProvider(testPath).future);
      expect(state.length, 1);
      expect((state.first).name, 'SMA 20');
    });

    test('updateIndicator modifies existing indicator', () async {
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0, name: 'Old', type: 'SMA', parameters: {},
      ));

      var state = await container.read(indicatorProvider(testPath).future);
      final savedIndicator = state.first;

      await notifier.updateIndicator(Indicator(
        id: savedIndicator.id,
        name: 'New',
        type: 'SMA',
        parameters: {'p': [1]},
        isEnabled: false,
      ));

      final newState = await container.read(indicatorProvider(testPath).future);
      final savedNewIndicator = newState.first;
      expect(savedNewIndicator.name, 'New');
      expect(savedNewIndicator.isEnabled, isFalse);
    });

    test('deleteIndicator removes an indicator', () async {
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0, name: 'T1', type: 'T', parameters: {},
      ));

      var state = await container.read(indicatorProvider(testPath).future);
      expect(state.length, 1);

      await notifier.deleteEntry(state.first);

      state = await container.read(indicatorProvider(testPath).future);
      expect(state, isEmpty);
    });

    test('toggleIndicator flips isEnabled', () async {
      final notifier = container.read(indicatorProvider(testPath).notifier);
      await notifier.addEntry(Indicator(
        id: 0, name: 'ToggleMe', type: 'T', parameters: {}, isEnabled: true,
      ));

      var state = await container.read(indicatorProvider(testPath).future);
      expect((state.first).isEnabled, isTrue);

      await notifier.toggleIndicator(state.first);

      state = await container.read(indicatorProvider(testPath).future);
      expect((state.first).isEnabled, isFalse);
    });
  });
}
