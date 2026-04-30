import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'load_database_provider.g.dart';

enum CacheKeyType {
  configCache("cache.db"),
  priceCache("cache.db"),
  analysisCache("analysis.db"),
  memoryCache(":memory:");

  const CacheKeyType(this.key);
  final String key;
}

@riverpod
class LoadDatabase extends _$LoadDatabase {

  @override
  FutureOr<String> build(CacheKeyType cacheTYpe) async {
    // Test propose or using runtime cache
    if (cacheTYpe == CacheKeyType.memoryCache) {
      return cacheTYpe.key;
    }

    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/cache/${cacheTYpe.key}');
    if (await file.exists()) {
      return file.path;
    }
    await file.create(recursive: false);
    return file.path;
  }
}

@Riverpod(keepAlive: true)
Future<DatabaseHelper> appConfig(Ref ref) async {
  // Watch the path. Whenever setPath is called, this provider will re-evaluate.
  final path = await ref.watch(loadDatabaseProvider(CacheKeyType.configCache).future);

  if (kDebugMode) {
    print("DatabaseHelper: $path");
  }
  final helper = DatabaseHelper(path);
  await helper.init();

  ref.onDispose(() {
    if (kDebugMode) {
      print("DatabaseHelper.dispose");
    }
  //  ref.invalidate(loadDatabaseProvider);
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

@riverpod
Future<DatabaseHelper> loadPrice(Ref ref, CacheKeyType? type, bool keepAlive) async {
  final link = keepAlive ? ref.keepAlive() : null;
  try {
    final path = await ref.watch(
        loadDatabaseProvider(type ?? CacheKeyType.priceCache).future);

    if (kDebugMode) {
      print("DatabaseHelper[]: $path");
    }
    final helper = DatabaseHelper(path);
    await helper.init();

    ref.onDispose(() {
      if (kDebugMode) {
        print("DatabaseHelper.dispose");
      }
       // ref.invalidate(loadDatabaseProvider);
      helper.dispose();
    });

    return helper;
  }
  finally {
    link?.close();
  }
}