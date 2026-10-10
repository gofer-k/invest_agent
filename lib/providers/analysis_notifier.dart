import 'package:flutter/cupertino.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cache_notifier.dart';
import 'load_database_provider.dart';
import 'model_config.dart';

part 'analysis_notifier.g.dart';

@immutable
class AnalysisState<TConfigCache extends Cache> {
  final List<TConfigCache> cachedConfig;

  const AnalysisState({this.cachedConfig = const []});

  AnalysisState<TConfigCache> copyWith({List<TConfigCache>? newCachedConfig}) {
    return AnalysisState<TConfigCache>(
      cachedConfig: newCachedConfig ?? cachedConfig,
    );
  }
  List<TConfigCache> getItems() => cachedConfig;
}

/// A mixin that provides common logic for analysis-based notifiers.
mixin AnalysisNotifierMixin<TConfigCache extends Cache, TSchema extends CacheSchema> {
  // Members provided by the Notifier class mixing this in.
  Ref get ref;
  AsyncValue<AnalysisState<TConfigCache>> get state;
  set state(AsyncValue<AnalysisState<TConfigCache>> value);

  late TSchema mixinSchema;
  late CacheKeyType mixinCacheKeyType;
  late String mixinDbPath;

  Future<String> getDbPath() async {
    if (!ref.mounted) return mixinDbPath;
    final path = await ref.read(loadDatabaseProvider(mixinCacheKeyType).future);
    if (ref.mounted) mixinDbPath = path;
    return mixinDbPath;
  }

  Future<List<TConfigCache>> fetchAll() async {
    if (!ref.mounted) return [];
    final path = await getDbPath();
    // Return items from the underlying cache provider
    return await ref.read(cacheProvider<TConfigCache, TSchema>(mixinSchema, path).future);
  }

  Future<void> addEntry(TConfigCache entry) async {
    if (!ref.mounted) return;
    final path = await getDbPath();
    await ref.read(cacheProvider<TConfigCache, TSchema>(mixinSchema, path).notifier).addEntry(entry);
    // No need to manually call fetchAll here as build() watches the cacheProvider
  }

  Future<void> updateEntry(TConfigCache entry) async {
    if (!ref.mounted) return;
    final path = await getDbPath();
    await ref.read(cacheProvider<TConfigCache, TSchema>(mixinSchema, path).notifier).updateEntry(entry);
  }

  Future<void> deleteEntry(TConfigCache entry) async {
    if (!ref.mounted) return;
    final path = await getDbPath();
    await ref.read(cacheProvider<TConfigCache, TSchema>(mixinSchema, path).notifier).deleteEntry(entry);
  }

  Future<void> clearAll() async {
    if (!ref.mounted) return;
    final path = await getDbPath();
    await ref.read(cacheProvider<TConfigCache, TSchema>(mixinSchema, path).notifier).clearAll();
  }
}

@riverpod
class AnalysisNotifier<TConfigCache extends Cache, TSchema extends CacheSchema>
  extends _$AnalysisNotifier<TConfigCache, TSchema> with AnalysisNotifierMixin<TConfigCache, TSchema> {

  @override
  Future<AnalysisState<TConfigCache>> build(TSchema schema, CacheKeyType type, [String? path]) async {
    mixinSchema = schema;
    mixinCacheKeyType = type;

    // Await prerequisites
    final dbPathResult = await ref.watch(loadDatabaseProvider(mixinCacheKeyType).future);
    await ref.watch(assetsLoaderProvider.future);

    mixinDbPath = path ?? dbPathResult;

    // Watch the underlying cache provider. This keeps it alive and reacts to changes.
    final items = await ref.watch(cacheProvider<TConfigCache, TSchema>(mixinSchema, mixinDbPath).future);
    return AnalysisState(cachedConfig: items);
  }
}
