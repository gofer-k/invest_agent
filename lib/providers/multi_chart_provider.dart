import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/asset_config.dart';
import '../model/chart_style.dart';
import 'cache_notifier.dart';
import 'load_database_provider.dart';

part 'multi_chart_provider.g.dart';

@immutable
class MultiChartNotifierState {
  final List<MultiChartConfig> cachedCharts;
  final PeriodType periodType;
  final ChartStyle chartStyle;
  const MultiChartNotifierState({
    this.periodType = PeriodType.year,
    this.cachedCharts = const [],
    this.chartStyle = ChartStyle.line});

  MultiChartNotifierState copyWith({
    PeriodType? periodTypeCache,
    ChartStyle? chartStyle,
    List<MultiChartConfig>? cache}) {
    return MultiChartNotifierState(
        periodType: periodTypeCache ?? periodType,
        chartStyle: chartStyle ?? this.chartStyle,
        cachedCharts: cache ?? cachedCharts);
  }

  List<MultiChartConfig> getItems() => cachedCharts;
}

@riverpod
class MultiChartNotifier extends _$MultiChartNotifier {
  static final _schema = MultiChartConfigSchema();

  MultiChartConfigSchema get schema => _schema;
  late String _dbPath;

  String get dbPath => _dbPath;

  Future<String> _getDbPath() async {
    if (!ref.mounted) return _dbPath;
    final path = await ref.read(
        loadDatabaseProvider(type ?? CacheKeyType.analysisCache).future);
    if (ref.mounted) _dbPath = path;
    return _dbPath;
  }

  @override
  MultiChartNotifierState build([
    CacheKeyType? type,
    PeriodType? periodType,
    ChartStyle? chartStyle,
    bool? keepAlive]) {
    if (keepAlive == true) ref.keepAlive();

    final pathAsync = ref.watch(
        loadDatabaseProvider(type ?? CacheKeyType.analysisCache));

    // Use AsyncValue to check if we have a valid path
    return pathAsync.maybeWhen(
      data: (path) {
        _dbPath = path;
        final cacheAsync = ref.watch(
            cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
                _schema, path));

        return MultiChartNotifierState(
            periodType: periodType ?? PeriodType.year,
            chartStyle: chartStyle ?? ChartStyle.line,
            cachedCharts: _filter(cacheAsync.value ?? const []));
      },
      orElse: () {
        _dbPath = "";
        return const MultiChartNotifierState();
      },
    );
  }

  List<MultiChartConfig> _filter(List<MultiChartConfig> items) {
    var charts = items;
    if (periodType != null) {
      charts = charts.where((c) => c.periodType == periodType).toList();
    }
    if (chartStyle != null) {
      charts = charts.where((c) => c.mainChart.chartStyle == chartStyle).toList();
    }
    return charts;
  }

  Future<List<MultiChartConfig>> fetchAll() async {
    if (!ref.mounted) return [];
    final path = await _getDbPath();
    if (!ref.mounted) return [];
    
    final items = await ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, path).notifier).fetchAll();
            
    if (!ref.mounted) return items;
    state = state.copyWith(cache: _filter(items));
    return items;
  }

  Future<void> addEntry(MultiChartConfig entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;
    
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, path).notifier);
    await notifier.addEntry(entry);
    
    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> updateMultiChart(MultiChartConfig entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;
    
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, path).notifier);
    await notifier.updateEntry(entry);
    
    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> deleteEntry(MultiChartConfig entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;
    
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, path).notifier);
    await notifier.deleteEntry(entry);
    
    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> clearAll() async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;
    
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, path).notifier);
    await notifier.clearAll();
    
    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> changePeriodType(PeriodType periodType) async {
    state = state.copyWith(periodTypeCache: periodType);
  }

  Future<void> changeChartStyle(ChartStyle style) async {
    state = state.copyWith(chartStyle: style);
  }
}

@riverpod
List<MultiChartConfig> sortedMultiCharts(Ref ref, CacheKeyType? type) {
  final charts = ref.watch(multiChartProvider(type).select((s) => s.cachedCharts));
  return charts.toList()..sort((a, b) => a.title.compareTo(b.title));
}

@riverpod
List<MultiChartConfig> multiChartsBy(Ref ref,
    CacheKeyType? type,
    AssetConfig asset,
    PeriodType periodType,
    ChartStyle style) {
  final charts = ref.watch(multiChartProvider(type, periodType, style).select((s) => s.cachedCharts));
  final filteredCharts = charts
      .where((chart) => chart.asset.id == asset.id)
      .map((chart) => chart.copyWith(newAsset: asset))
      .toList();
  return filteredCharts;
}

@riverpod
Future<void> removeMultiChartBy(Ref ref, CacheKeyType? type, AssetConfig asset) async {
  for (final chart in ref.read(multiChartProvider(type).select((s) => s.cachedCharts))) {
    if (chart.asset.id == asset.id) {
      await ref.read(multiChartProvider(type).notifier).deleteEntry(chart);
    }
  }
}
