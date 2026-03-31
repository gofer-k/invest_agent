import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

const String _dbPathKey = 'persistent_db_path';
const String _defaultDbName = 'cache.db';

@riverpod
class DatabasePath extends _$DatabasePath {
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<String> build() async {
    final savedPath = await _storage.read(key: _dbPathKey);
    if (kDebugMode) {
      print("DatabasePath.build: ${savedPath ?? _defaultDbName}");
    }
    return savedPath ?? _defaultDbName;
  }

  Future<void> setPath(String newPath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _storage.write(key: _dbPathKey, value: newPath);
      if (kDebugMode) {
        print("DatabasePath.setPath: $newPath");
      }
      return newPath;
    });
  }
}

@riverpod
Future<DatabaseHelper> databaseHelper(Ref ref) async {
  // Watch the path. Whenever setPath is called, this provider will re-evaluate.
  final path = await ref.watch(databasePathProvider.future);

  if (kDebugMode) {
    print("DatabaseHelper: $path");
  }
  final helper = DatabaseHelper(path);
  await helper.init();
  return helper;
}
