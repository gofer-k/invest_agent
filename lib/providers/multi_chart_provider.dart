import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/asset_config.dart';
import 'cache_notifier.dart';
import 'load_database_provider.dart';

part 'multi_chart_provider.g.dart';

@immutable
class MultiChartNotifierState {
  final List<MultiChartConfig> cachedCharts;
  final PeriodType periodType;
  const MultiChartNotifierState({this.periodType = PeriodType.year, this.cachedCharts = const []});

  MultiChartNotifierState copyWith({PeriodType? periodTypeCache, List<MultiChartConfig>? cache}) {
    return MultiChartNotifierState(
        periodType: periodTypeCache ?? periodType,
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
    return await ref.read(
        loadDatabaseProvider(type ?? CacheKeyType.analysisCache).future);
  }

  @override
  MultiChartNotifierState build([
    CacheKeyType? type,
    PeriodType? periodType,
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
            cachedCharts: cacheAsync.value ?? const []);
      },
      orElse: () {
        _dbPath = "";
        return const MultiChartNotifierState();
      },
    );
  }

  Future<List<MultiChartConfig>> fetchAll() async {
    await _getDbPath();
    final items = await ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, _dbPath).notifier).fetchAll();
    if (!ref.mounted) return items;
    state = state.copyWith(cache: items);
    return items;
  }

  Future<void> addEntry(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, _dbPath).notifier);
    await notifier.addEntry(entry);
    await fetchAll();
  }

  Future<void> updateMultiChart(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, _dbPath).notifier);
    await notifier.updateEntry(entry);
    await fetchAll();
  }

  Future<void> deleteEntry(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, _dbPath).notifier);
    await notifier.deleteEntry(entry);
    await fetchAll();
  }

  Future<void> clearAll() async {
    await _getDbPath();
    final notifier = ref.read(
        cacheProvider<MultiChartConfig, MultiChartConfigSchema>(
            _schema, _dbPath).notifier);
    await notifier.clearAll();
    await fetchAll();
  }

  Future<void> changePeriodType(PeriodType periodType) async {
    state = state.copyWith(periodTypeCache: periodType);
  }
}

@riverpod
List<MultiChartConfig> sortedMultiCharts(Ref ref, CacheKeyType? type) {
  final charts = ref.watch(multiChartProvider(type).select((s) => s.cachedCharts));
  return charts.toList()..sort((a, b) => a.title.compareTo(b.title));
}

@riverpod
List<MultiChartConfig> multiChartsBy(Ref ref, CacheKeyType? type, AssetConfig asset, PeriodType periodType) {
  final charts = ref.watch(multiChartProvider(type, periodType).select((s) => s.cachedCharts));
  return charts.where((chart) => chart.asset.id == asset.id).toList();
}