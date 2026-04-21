import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_schema.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/providers/analysis_provider.dart';
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
      // Ignored for environments where duckdb might not be available or already loaded
    }
  });

  group('AnalysisNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final schema = AnalysisSchema();

    final testRequest = AnalysisRequest(
      symbolTicker: "AAPL",
      datasetSource: "marketstack",
      period: PeriodType.year,
      interval: IntervalType.day,
    );

    setUp(() async {
      // Use in-memory database for testing
      dbHelper = DatabaseHelper(":memory:");
      await dbHelper.init();
      await dbHelper.createCache(schema);

      container = ProviderContainer(
        overrides: [
          analysisDatabaseHelperProvider.overrideWith((ref) => dbHelper),
        ],
      );
      container.listen(analysisProvider, (_, _) {});
    });

    tearDown(() {
      dbHelper.dispose();
      container.dispose();
    });

    test('Initial state is empty list', () async {
      final state = await container.read(analysisProvider.future);
      expect(state, isEmpty);
    });

    test('addEntry adds an entry and updates state', () async {
      final entry = AnalysisEntry(
        userId: 1,
        request: testRequest,
        createdAt: DateTime.now(),
      );

      final notifier = container.read(analysisProvider.notifier);
      await notifier.addEntry(entry);

      final state = await container.read(analysisProvider.future);
      expect(state.length, 1);
      expect(state.first.request?.symbolTicker, "AAPL");
    });

    test('deleteEntry removes an entry', () async {
       final entry = AnalysisEntry(
        id: 1,
        userId: 1,
        request: testRequest,
        createdAt: DateTime.now(),
      );

      final notifier = container.read(analysisProvider.notifier);
      await notifier.addEntry(entry);
      
      var state = await container.read(analysisProvider.future);
      expect(state.length, 1);

      await notifier.deleteEntry(state.first);
      
      state = await container.read(analysisProvider.future);
      expect(state, isEmpty);
    });

    test('clearAll removes all entries', () async {
      final notifier = container.read(analysisProvider.notifier);
      
      await notifier.addEntry(AnalysisEntry(
        userId: 1, request: testRequest, createdAt: DateTime.now(),
      ));
      await notifier.addEntry(AnalysisEntry(
        userId: 1, request: testRequest, createdAt: DateTime.now(),
      ));

      var state = await container.read(analysisProvider.future);
      expect(state.length, 2);

      await notifier.clearAll();
      
      state = await container.read(analysisProvider.future);
      expect(state, isEmpty);
    });
  });
}
