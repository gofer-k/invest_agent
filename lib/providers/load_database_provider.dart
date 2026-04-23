import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_database_provider.g.dart';

const String _dbPathKey = 'persistent_db_path';
const String _defaultDbName = 'cache.db';

@riverpod
class LoadDatabase extends _$LoadDatabase {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<String> build() async {
    final savedPath = await _storage.read(key: _dbPathKey);
    if (kDebugMode) {
      print("LoadDatabase.build: ${savedPath ?? _defaultDbName}");
    }
    return savedPath ?? _defaultDbName;
  }

  Future<void> setPath(String newPath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _storage.write(key: _dbPathKey, value: newPath);
      if (kDebugMode) {
        print("LoadDatabase.setPath: $newPath");
      }
      return newPath;
    });
  }
}

@Riverpod(keepAlive: true)
Future<DatabaseHelper> databaseHelper(Ref ref) async {
  // Watch the path. Whenever setPath is called, this provider will re-evaluate.
  final path = await ref.watch(loadDatabaseProvider.future);

  if (kDebugMode) {
    print("DatabaseHelper: $path");
  }
  final helper = DatabaseHelper(path);
  await helper.init();

  ref.onDispose(() {
    if (kDebugMode) {
      print("DatabaseHelper.dispose");
    }
    ref.invalidate(loadDatabaseProvider);
    helper.dispose();
  });

  return helper;
}

@riverpod
Future<DatabaseHelper> appCacheHelper(Ref ref, String path, CacheSchema schema) async {
  // Use a separate database file for analysis cache
  final helper = DatabaseHelper(path);
  await helper.init();

  // Ensure table is created
  await helper.createCache(schema);

  ref.onDispose(() {
    helper.dispose();
  });
  return helper;
}