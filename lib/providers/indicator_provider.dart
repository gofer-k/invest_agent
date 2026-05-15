import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cache_notifier.dart';
import 'load_database_provider.dart';
part 'indicator_provider.g.dart';

@immutable
class IndicatorNotifierState {
  final List<Indicator> cache;
  const IndicatorNotifierState({this.cache = const []});

  IndicatorNotifierState copyWith({List<Indicator>? cache}) {
    return IndicatorNotifierState(cache: cache ?? this.cache);
  }

  List<Indicator> getItems() => cache;
}

@riverpod
class IndicatorNotifier extends _$IndicatorNotifier {
  static final _schema = IndicatorSchema();

  IndicatorSchema get schema => _schema;
  late String _dbPath;
  String get dbPath => _dbPath;

  Future<String> _getDbPath() async {
    return await ref.read(loadDatabaseProvider(type ?? CacheKeyType.analysisCache).future);
  }

  @override
  IndicatorNotifierState build([CacheKeyType? type, bool? keepAlive]) {
    if (keepAlive == true) ref.keepAlive();

    final pathAsync = ref.watch(loadDatabaseProvider(type ?? CacheKeyType.analysisCache));

    // Use AsyncValue to check if we have a valid path
    return pathAsync.maybeWhen(
      data: (path) {
        _dbPath = path;
        final cacheAsync = ref.watch(cacheProvider<Indicator, IndicatorSchema>(_schema, path));
        return IndicatorNotifierState(cache: cacheAsync.value ?? const []);
      },
      orElse: () {
        _dbPath = "";
        return const IndicatorNotifierState();
      },
    );
  }

  Future<List<Indicator>> fetchAll() async {
    await _getDbPath();
    final items = await ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier).fetchAll();
    if (!ref.mounted) return items;
    state = state.copyWith(cache: items);
    return items;
  }

  Future<void> addEntry(Indicator entry) async {
    // Just perform the mutation. The reactive 'watch' above handles the UI update.
    await _getDbPath();
    final notifier = ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, _dbPath).notifier);
    await notifier.addEntry(entry);
    await fetchAll();
  }

  Future<void> updateIndicator(Indicator entry) async {
    await _getDbPath();
    final notifier = ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier);
    await notifier.updateEntry(entry);
    await fetchAll();
  }

  Future<void> deleteEntry(Indicator entry) async {
    await _getDbPath();
    final notifier =  ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier);
    await notifier.deleteEntry(entry);
    await fetchAll();
  }

  Future<void> clearAll() async {
    await _getDbPath();
    final notifier =ref.read(cacheProvider<Indicator, IndicatorSchema>(_schema, dbPath).notifier);
    await notifier.clearAll();
    await fetchAll();
  }
}

@riverpod
List<Indicator> sortedIndicators(Ref ref) {
  final cachedIndicators = ref.watch(indicatorProvider().select(
          (s) => s.getItems()));

  final indicators = <Indicator>[Indicator.defaultIndicator()];
  indicators.addAll(cachedIndicators);
  return indicators.toList()..sort((a, b) => a.name.compareTo(b.name));
}
