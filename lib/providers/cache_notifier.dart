import 'package:invest_agent/model/cache_schema.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'load_database_provider.dart';

part 'cache_notifier.g.dart';

@riverpod
class CacheNotifier<T extends Cache, TSchema extends CacheSchema> extends _$CacheNotifier<T, TSchema> {
  late TSchema _schema;
  TSchema get schema => _schema;

  late String _dbPath;
  String get dbPath => _dbPath;

  @override
  Future<List<T>> build(TSchema cacheSchema, String cachePath) async {
    _schema = cacheSchema;
    _dbPath = cachePath;

    final helper = await ref.watch(appCacheHelperProvider(_dbPath, _schema).future);
    await helper.createCache(_schema);
    return helper.fetchAll<T>(_schema);
  }

  Future<void> addEntry(T entry) async {
    final helper = await ref.read(appCacheHelperProvider(_dbPath, schema).future);
    await helper.saveOne(_schema, entry);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(T entry) async {
      final helper = await ref.read(appCacheHelperProvider(_dbPath, _schema).future);
      await helper.updateOne(_schema, entry);
      ref.invalidateSelf();
  }

  Future<void> deleteEntry(T entry) async {
    final helper = await ref.read(appCacheHelperProvider(_dbPath, _schema).future);
    await helper.deleteOne(_schema, entry);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final helper = await ref.read(appCacheHelperProvider(_dbPath, _schema).future);
    await helper.deleteAll(_schema);
    ref.invalidateSelf();
  }
}

