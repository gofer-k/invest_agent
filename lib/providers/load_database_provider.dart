import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'load_database_provider.g.dart';

enum CacheKeyType {
  configCache("cache.db"),
  priceCache("cache.db"),
  analysisCache("analysis.db"),
  memoryCache(":memory:"),
  tempFile("temp");

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

    final directory = await getApplicationSupportDirectory();
    final dbDir = Directory('${directory.path}/cache');
    
    // Ensure the subdirectory exists
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final file = File('${dbDir.path}/${cacheTYpe.key}');
    
    // If the file doesn't exist locally, copy it from assets
    if (!await file.exists()) {
      if (kDebugMode) {
        dev.log("Database not found at ${file.path}. Copying from assets...");
      }
      
      try {
        // Load from assets (paths must match pubspec.yaml)
        final data = await rootBundle.load('cache/${cacheTYpe.key}');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        
        // Write to local filesystem
        await file.writeAsBytes(bytes, flush: true);
      } catch (e) {
        if (kDebugMode) {
          print("Error copying database from assets: $e");
        }
        // Fallback: create empty file if asset is missing
        await file.create();
      }
    }

    return file.path;
  }

  Future<void> clearSandbox() async {
    final directory = await getApplicationSupportDirectory();
    final dbDir = Directory('${directory.path}/cache');

    if (await dbDir.exists()) {
      // This deletes the folder and everything inside it
      await dbDir.delete(recursive: true);
      dev.log("Sandbox cleared.");
    }
  }
}

@Riverpod(keepAlive: true)
Future<DatabaseHelper> appConfig(Ref ref) async {
  // Watch the path. Whenever setPath is called, this provider will re-evaluate.
  final path = await ref.watch(loadDatabaseProvider(CacheKeyType.configCache).future);

  if (kDebugMode) {
    print("appConfigProvider: $path");
  }
  final helper = DatabaseHelper(cacheFile:  path);
  await helper.init();

  ref.onDispose(() {
    if (kDebugMode) {
      print("appConfigProvider.dispose");
    }
    helper.dispose();
  });

  return helper;
}

@riverpod
Future<DatabaseHelper> appCacheHelper(Ref ref, String path, CacheSchema schema) async {
  ref.keepAlive();

  // Use a separate database file for analysis cache
  final helper = DatabaseHelper(cacheFile: path);
  await helper.init();

  if (kDebugMode) {
    print("appCacheHelperProvider: $path");
  }

  // Ensure table is created
  await helper.createCache(schema);

  ref.onDispose(() {
    if (kDebugMode) {
      print("appCacheHelperProvider.dispose");
    }
    helper.dispose();
  });
  return helper;
}


@riverpod
Future<DatabaseHelper> loadPrice(Ref ref, CacheKeyType? type, bool keepAlive) async {
  ref.keepAlive();
  final path = await ref.watch(
      loadDatabaseProvider(type ?? CacheKeyType.priceCache).future);

  final pathKey = type ?? CacheKeyType.priceCache.key;
  if (kDebugMode) {
    print("loadPriceProvider[$pathKey]: $path");
  }
  final helper = DatabaseHelper(cacheFile: path);
  await helper.init();

  ref.onDispose(() {
    if (kDebugMode) {
      print("loadPriceProvider[$pathKey].dispose");
    }
    helper.dispose();
  });

  return helper;
}