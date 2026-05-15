import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/drawing_schema.dart';
import 'package:invest_agent/model/indicator_result.dart';
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
    final AssetConfig asset = AssetConfig.defaultAsset();

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
      expect(state.cachedCharts, isEmpty);
    });

    test('addEntry adds a chart and updates state', () async {
      await container.read(loadDatabaseProvider(testPath).future);
      
      final config = MultiChartConfig(id: 1, title: 'Test Chart', periodType: PeriodType.year, charts: [
        ChartConfig(mainChart: true, chartStyle: ChartStyle.line,
          drawingData: [
            LineFeature(begin: Point(0, 0), end: Point(10, 20))
          ],
          indicatorConfig: Indicator.priceIndicator()),
        ChartConfig(mainChart: false, chartStyle: ChartStyle.bars,
          indicatorConfig: Indicator(id: 0, name: "SMA", type: IndicatorType.sma,
            parameters: {"window": 20})),
      ], asset: asset);
      
      final notifier = container.read(multiChartProvider(testPath).notifier);
      await notifier.addEntry(config);
      
      final state = container.read(multiChartProvider(testPath));
      expect(state.cachedCharts.length, 1);
      expect(state.cachedCharts.first.title, 'Test Chart');
      expect(state.cachedCharts.first.charts.length, 2);
      expect(state.cachedCharts.first.charts.last.indicatorConfig.name, 'SMA');
      expect(state.cachedCharts.first.charts.last.indicatorConfig.parameters['window'], 20);
      expect(state.cachedCharts.first.charts.last.indicatorConfig.isDefault(), false);
      expect(state.cachedCharts.first.charts.last.indicatorConfig.id, 0);
      expect(state.cachedCharts.first.charts.last.indicatorConfig.type, IndicatorType.sma);

      expect(state.cachedCharts.first.charts.first.drawingData.length, 1);
      final cachedLine = state.cachedCharts.first.charts.first.drawingData.first as LineFeature;
      expect(cachedLine.begin, (config.charts.first.drawingData.first as LineFeature).begin);
      expect(cachedLine.end, (config.charts.first.drawingData.first as LineFeature).end);
      expect(cachedLine.color, (config.charts.first.drawingData.first as LineFeature).color);
      expect(cachedLine.width, (config.charts.first.drawingData.first as LineFeature).width);
      expect(cachedLine.style, (config.charts.first.drawingData.first as LineFeature).style);
    });

    test('updateMultiChart updates a chart', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart', asset: asset);
       await container.read(multiChartProvider(testPath).notifier).addEntry(config);
       
       var state = container.read(multiChartProvider(testPath));
       final added = state.cachedCharts.first;
       
       final updatedConfig = added.copyWith(newTitle: 'Updated Chart');
       await container.read(multiChartProvider(testPath).notifier).updateMultiChart(updatedConfig);
       
       state = container.read(multiChartProvider(testPath));
       expect(state.cachedCharts.first.title, 'Updated Chart');
    });

    test('deleteEntry removes a chart', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final config = MultiChartConfig(id: 1, title: 'Test Chart', asset: asset);
       await container.read(multiChartProvider(testPath).notifier).addEntry(config);
       
       var state = container.read(multiChartProvider(testPath));
       expect(state.cachedCharts.length, 1);
       
       await container.read(multiChartProvider(testPath).notifier).deleteEntry(state.cachedCharts.first);
       
       state = container.read(multiChartProvider(testPath));
       expect(state.cachedCharts, isEmpty);
    });

    test('clearAll removes all charts', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final notifier = container.read(multiChartProvider(testPath).notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'A', asset: asset));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'B', asset: asset));
       
       expect(container.read(multiChartProvider(testPath)).cachedCharts.length, 2);
       
       await notifier.clearAll();
       
       expect(container.read(multiChartProvider(testPath)).cachedCharts, isEmpty);
    });

    test('sortedMultiCharts returns sorted list', () async {
       await container.read(loadDatabaseProvider(testPath).future);
       
       final notifier = container.read(multiChartProvider(testPath).notifier);
       await notifier.addEntry(MultiChartConfig(id: 1, title: 'C', asset: asset));
       await notifier.addEntry(MultiChartConfig(id: 2, title: 'A', asset: asset));
       await notifier.addEntry(MultiChartConfig(id: 3, title: 'B', asset: asset));
       
       final sorted = container.read(sortedMultiChartsProvider(testPath));
       expect(sorted.map((e) => e.title).toList(), ['A', 'B', 'C']);
    });
  });
}
