
import 'package:flutter/material.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cache_notifier.dart';
import 'load_database_provider.dart';

part 'strategy_provider.g.dart';

@immutable
class StrategyNotifierState {
  final List<Strategy> cachedStrategies;
  const StrategyNotifierState({this.cachedStrategies = const []});

  StrategyNotifierState copyWith({
    List<Strategy>? newCache}) {
    return StrategyNotifierState(
      cachedStrategies: newCache ?? cachedStrategies,
    );
  }
  List<Strategy> getItems() => cachedStrategies;
}

@riverpod
class StrategyNotifier extends _$StrategyNotifier {
  static final _schema = StrategySchema();

  StrategySchema get schema => _schema;
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
  StrategyNotifierState build([CacheKeyType? type, bool? keepAlive]) {
    if (keepAlive == true) ref.keepAlive();

    final pathAsync = ref.watch(
      loadDatabaseProvider(type ?? CacheKeyType.analysisCache));

    // Use AsyncValue to check if we have a valid path
    return pathAsync.maybeWhen(
      data: (path) {
        _dbPath = path;
        final cacheAsync = ref.watch(
            cacheProvider<Strategy, StrategySchema>(_schema, path));

        return StrategyNotifierState(cachedStrategies: cacheAsync.value ?? const []);
      },
      orElse: () {
        _dbPath = "";
        return const StrategyNotifierState();
      },
    );
  }

  Future<List<Strategy>> fetchAll() async {
    if (!ref.mounted) return [];
    final path = await _getDbPath();
    if (!ref.mounted) return [];

    final items = await ref.read(
        cacheProvider<Strategy, StrategySchema>(_schema, path).notifier)
        .fetchAll();

    if (!ref.mounted) return items;
    state = state.copyWith(newCache: items);
    return items;
  }

  Future<void> addEntry(Strategy entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;

    final notifier = ref.read(
        cacheProvider<Strategy, StrategySchema>(_schema, path).notifier);
    await notifier.addEntry(entry);

    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> updateEntry(Strategy entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;

    final notifier = ref.read(
        cacheProvider<Strategy, StrategySchema>(_schema, path).notifier);
    await notifier.updateEntry(entry);

    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> deleteEntry(Strategy entry) async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;

    final notifier = ref.read(
        cacheProvider<Strategy, StrategySchema>(_schema, path).notifier);
    await notifier.deleteEntry(entry);

    if (!ref.mounted) return;
    await fetchAll();
  }

  Future<void> clearAll() async {
    if (!ref.mounted) return;
    final path = await _getDbPath();
    if (!ref.mounted) return;

    final notifier = ref.read(
        cacheProvider<Strategy, StrategySchema>(_schema, path).notifier);
    await notifier.clearAll();

    if (!ref.mounted) return;
    await fetchAll();
  }
}