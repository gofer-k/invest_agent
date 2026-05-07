import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/drawing_schema.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/multi_chart_provider.dart';
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
    const testPath = CacheKeyType.memoryCache;

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: testPath.key);
      await dbHelper.init();
      await dbHelper.createCache(schema);

      container = ProviderContainer(
        overrides: [

        ],
      );
      container.listen(multiChartProvider(testPath), (_,_){});
    });

    tearDown(() {
      container.dispose();
      dbHelper.dispose();
    });

    test('Initial state is empty', () async {
      // await container.read(loadDatabaseProvider(CacheKeyType.analysisCache).future);
      final state = container.read(multiChartProvider());
      expect(state.cache, isEmpty);
    });

    test('addEntry adds a chart and updates state', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      
      final config = MultiChartConfig(id: 1, title: 'Test Chart', charts: [
        ChartConfig(mainChart: true, drawingType: ChartType.linePrice,
          drawingData: [
            LineFeature(begin: Point(0, 0), end: Point(10, 20))
          ]),
        ChartConfig(mainChart: false, drawingType: ChartType.bars,
          indicator: Indicator(id: 0, name: "SMA", type: "Moving Average",
            parameters: {"window": 20})),
      ]);
      
      final notifier = container.read(multiChartProvider(testPath).notifier);
      await notifier.addEntry(config);
      
      final state = container.read(multiChartProvider(testPath));
      expect(state.cache.length, 1);
      expect(state.cache.first.title, 'Test Chart');
      expect(state.cache.first.charts.length, 2);
      expect(state.cache.first.charts.last.indicator?.name, 'SMA');
      expect(state.cache.first.charts.last.indicator?.parameters['window'], 20);
      expect(state.cache.first.charts.last.indicator?.isDefault(), false);
      expect(state.cache.first.charts.last.indicator?.id, 0);
      expect(state.cache.first.charts.last.indicator?.type, 'Moving Average');

      expect(state.cache.first.charts.first.drawingData.length, 1);
      final cachedLine = state.cache.first.charts.first.drawingData.first as LineFeature;
      expect(cachedLine.begin, (config.charts.first.drawingData.first as LineFeature).begin);
      expect(cachedLine.end, (config.charts.first.drawingData.first as LineFeature).end);
      expect(cachedLine.color, (config.charts.first.drawingData.first as LineFeature).color);
      expect(cachedLine.width, (config.charts.first.drawingData.first as LineFeature).width);
      expect(cachedLine.style, (config.charts.first.drawingData.first as LineFeature).style);
    });

    test('updateMultiChart updates a chart', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart');
       await container.read(multiChartProvider(testPath).notifier).addEntry(config);
       
       var state = container.read(multiChartProvider(testPath));
       final added = state.cache.first;
       
       final updatedConfig = added.copyWith(null, 'Updated Chart', null);
       await container.read(multiChartProvider(testPath).notifier).updateMultiChart(updatedConfig);
       
       state = container.read(multiChartProvider(testPath));
       expect(state.cache.first.title, 'Updated Chart');
    });

    test('deleteEntry removes a chart', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart');
       await container.read(multiChartProvider(testPath).notifier).addEntry(config);
       
       var state = container.read(multiChartProvider(testPath));
       expect(state.cache.length, 1);
       
       await container.read(multiChartProvider(testPath).notifier).deleteEntry(state.cache.first);
       
       state = container.read(multiChartProvider(testPath));
       expect(state.cache, isEmpty);
    });

    test('clearAll removes all charts', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final notifier = container.read(multiChartProvider(testPath).notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'A'));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'B'));
       
       expect(container.read(multiChartProvider(testPath)).cache.length, 2);
       
       await notifier.clearAll();
       
       expect(container.read(multiChartProvider(testPath)).cache, isEmpty);
    });

    test('sortedMultiCharts returns sorted list', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final notifier = container.read(multiChartProvider(testPath).notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'C'));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'A'));
       await notifier.addEntry(MultiChartConfig(id: 3, title: 'B'));
       
       final sorted = container.read(sortedMultiChartsProvider(testPath));
       expect(sorted.map((e) => e.title).toList(), ['A', 'B', 'C']);
    });
  });
}
