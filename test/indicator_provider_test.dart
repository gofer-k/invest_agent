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
    final schema = IndicatorSchema();

    setUp(() async {
      // Use in-memory database for testing
      dbHelper = DatabaseHelper(":memory:");
      await dbHelper.init();
      await dbHelper.createCache(schema);

      container = ProviderContainer(
        overrides: [
          databaseHelperProvider.overrideWith((ref) => dbHelper),
        ],
      );
      // Listen to ensure the provider is active
      container.listen(indicatorProvider, (_, _) {});
    });

    tearDown(() {
      dbHelper.dispose();
      container.dispose();
    });

    test('Initial state is empty list', () async {
      final state = await container.read(indicatorProvider.future);
      expect(state, isEmpty);
    });

    test('addIndicator adds an indicator and updates state', () async {
      final indicator = Indicator(
        id: 0,
        name: 'SMA 20',
        type: 'SMA',
        parameters: {'window': 20},
      );

      final notifier = container.read(indicatorProvider.notifier);
      await notifier.addIndicator(indicator);

      final state = await container.read(indicatorProvider.future);
      expect(state.length, 1);
      expect(state.first.name, 'SMA 20');
      expect(state.first.parameters['window'], 20);
    });

    test('updateIndicator modifies existing indicator', () async {
      final indicator = Indicator(
        id: 0,
        name: 'SMA 20',
        type: 'SMA',
        parameters: {'window': 20},
      );

      final notifier = container.read(indicatorProvider.notifier);
      await notifier.addIndicator(indicator);
      
      var state = await container.read(indicatorProvider.future);
      final savedIndicator = state.first;

      final updated = Indicator(
        id: savedIndicator.id,
        name: 'Fast SMA',
        type: 'SMA',
        parameters: {'window': 10},
        isEnabled: false,
      );

      await notifier.updateIndicator(updated);

      final newState = await container.read(indicatorProvider.future);
      expect(newState.first.name, 'Fast SMA');
      expect(newState.first.parameters['window'], 10);
      expect(newState.first.isEnabled, isFalse);
    });

    test('deleteIndicator removes an indicator', () async {
      final notifier = container.read(indicatorProvider.notifier);
      await notifier.addIndicator(Indicator(
        id: 0, name: 'T1', type: 'T', parameters: {},
      ));

      var state = await container.read(indicatorProvider.future);
      expect(state.length, 1);

      await notifier.deleteIndicator(state.first);

      state = await container.read(indicatorProvider.future);
      expect(state, isEmpty);
    });

    test('toggleIndicator flips isEnabled', () async {
      final notifier = container.read(indicatorProvider.notifier);
      await notifier.addIndicator(Indicator(
        id: 0, name: 'T1', type: 'T', parameters: {}, isEnabled: true,
      ));

      var state = await container.read(indicatorProvider.future);
      expect(state.first.isEnabled, isTrue);

      await notifier.toggleIndicator(state.first);

      state = await container.read(indicatorProvider.future);
      expect(state.first.isEnabled, isFalse);
    });
  });
}
