import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cache_notifier.dart';
import 'load_database_provider.dart';

part 'multi_chart_provider.g.dart';

@immutable
class MultiChartNotifierState {
  final List<MultiChartConfig> cache;
  const MultiChartNotifierState({this.cache = const []});

  MultiChartNotifierState copyWith({List<MultiChartConfig>? cache}) {
    return MultiChartNotifierState(cache: cache ?? this.cache);
  }

  List<MultiChartConfig> getItems() => cache;
}

@riverpod
class MultiChartNotifier extends _$MultiChartNotifier {
  static final _schema = MultiChartConfigSchema();

  MultiChartConfigSchema get schema => _schema;
  late String _dbPath;
  String get dbPath => _dbPath;

  Future<String> _getDbPath() async {
    return await ref.read(loadDatabaseProvider(type ?? CacheKeyType.analysisCache).future);
  }

  @override
  MultiChartNotifierState build([CacheKeyType? type, bool? keepAlive]) {
    if (keepAlive == true) ref.keepAlive();

    final pathAsync = ref.watch(loadDatabaseProvider(type ?? CacheKeyType.analysisCache));

    // Use AsyncValue to check if we have a valid path
    return pathAsync.maybeWhen(
      data: (path) {
        _dbPath = path;
        final cacheAsync = ref.watch(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, path));
        return MultiChartNotifierState(cache: cacheAsync.value ?? const []);
      },
      orElse: () {
        _dbPath = "";
        return const MultiChartNotifierState();
      },
    );
  }

  Future<List<MultiChartConfig>> fetchAll() async {
    await _getDbPath();
    final items = await ref.read(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, _dbPath).notifier).fetchAll();
    if (!ref.mounted) return items;
    state = state.copyWith(cache: items);
    return items;
  }

  Future<void> addEntry(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, _dbPath).notifier);
    await notifier.addEntry(entry);
    await fetchAll();
  }

  Future<void> updateMultiChart(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, _dbPath).notifier);
    await notifier.updateEntry(entry);
    await fetchAll();
  }

  Future<void> deleteEntry(MultiChartConfig entry) async {
    await _getDbPath();
    final notifier = ref.read(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, _dbPath).notifier);
    await notifier.deleteEntry(entry);
    await fetchAll();
  }

  Future<void> clearAll() async {
    await _getDbPath();
    final notifier = ref.read(cacheProvider<MultiChartConfig, MultiChartConfigSchema>(_schema, _dbPath).notifier);
    await notifier.clearAll();
    await fetchAll();
  }
}

@riverpod
List<MultiChartConfig> sortedMultiCharts(Ref ref, CacheKeyType? type) {
  final charts = ref.watch(multiChartProvider(type).select((s) => s.getItems()));
  return charts.toList()..sort((a, b) => a.title.compareTo(b.title));
}
