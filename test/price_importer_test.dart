import 'dart:developer' as dev;
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/price_result.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/price_importer_csv.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    try {
      final ldPath = Platform.environment['DUCKDB_PATH'];
      bool loaded = false;
      if (ldPath != null) {
        for (final path in ldPath.split(':')) {
          final file = File('$path/libduckdb.so');
          if (file.existsSync()) {
            DynamicLibrary.open(file.path);
            loaded = true;
            break;
          }
        }
      }
      if (!loaded) {
        final homePath = Platform.environment['HOME'];
        final duckDbFile = '$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so';
        if (File(duckDbFile).existsSync()) {
          DynamicLibrary.open(duckDbFile);
        }
      }
    } catch (e) {
      dev.log('DuckDB Library load info: $e');
    }
  });

  group('PriceImporter Integration Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    late Directory tempDir;
    const keepAlive = true;
    final testAsset = AssetConfig(
      id: 1,
      symbol: "TEST_ASSET",
      currency: FiatUsd(),
      stockExchange: StockExchange.xWar,
    );
    File? csvFile;

    setUp(() async {
      // Initialize in-memory DuckDB
      dbHelper = DatabaseHelper(cacheFile: ':memory:');
      await dbHelper.init();
      
      // Initialize required schemas
      await dbHelper.createCache(IndexPriceSchema());
      await dbHelper.createCache(AssetConfigSchema());
      
      // Register the test asset in the DB
      await dbHelper.saveOne(AssetConfigSchema(), testAsset);

      // Create a temporary directory for test CSV files
      tempDir = await Directory.systemTemp.createTemp('price_importer_test');
      csvFile = File('${tempDir.path}/TEST_ASSET.csv');

      container = ProviderContainer(
        overrides: [
          loadPriceProvider(CacheKeyType.memoryCache, keepAlive).overrideWith((ref) => dbHelper),
        ],
      );

      // Setup the importer with our temp directory path
      // await container.read(loadPriceProvider(CacheKeyType.memoryCache, keepAlive).future);

      // container.listen(priceControllerProvider(CacheKeyType.memoryCache, keepAlive), (_, _) {});
      container.listen(priceImporterProvider(CacheKeyType.memoryCache, tempDir.path), (_, _){});
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
      dbHelper.dispose();
      container.dispose();
    });

    test('Successfully imports CSV and verifies data via PriceController', () async {
      await csvFile?.writeAsString(
      '''
      "Date","Price","Open","High","Low","Vol.","Change %"
      "06/01/2023","120.50","118.00","122.00","117.50","5.5K","2.1%"
      "06/02/2023","125.00","121.00","126.00","120.00","1.2M","3.7%"
      ''');

      final importer = container.read(priceImporterProvider(CacheKeyType.memoryCache, tempDir.path).notifier);
      final importedPrices = await importer.importFromCsv(testAsset);

      expect(importedPrices.length, 2);
      
      final day1 = importedPrices.firstWhere((p) => p.dateTime.day == 1);
      expect(day1.closePrice, 120.50);
      expect(day1.volume, 5500.0);
      
      final day2 = importedPrices.firstWhere((p) => p.dateTime.day == 2);
      expect(day2.closePrice, 125.00);
      expect(day2.volume, 1200000.0);
    });

    test('Volume parsing handles suffixes correctly', () async {
      expect(PriceImporter.parseVolume("1.5K"), 1500.0);
      expect(PriceImporter.parseVolume("2.1M"), 2100000.0);
      expect(PriceImporter.parseVolume("1B"), 1000000000.0);
      expect(PriceImporter.parseVolume("-"), 0.0);
    });
  });
}
