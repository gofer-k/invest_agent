import 'dart:developer' as dev;
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/index_price.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/model_config.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    try {
      // DUCKDB_PATH="/home/chris/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release";
      final ldPath = Platform.environment['DUCKDB_PATH'];
      bool loaded = false;
      if (ldPath != null) {
        // Split by ':' on Linux/macOS
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
        // Fallback: Try to let the system find it in standard paths.
        // Even if Platform.environment['LD_LIBRARY_PATH'] is null,
        // the OS loader might still have access to it if it was inherited.
        final homePath = Platform.environment['HOME'];
        DynamicLibrary.open('$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so');
      }
    } catch (e) {
      // It might already be loaded or fail if not found anywhere
      dev.log('Library load info: $e');
      exit(-1);
    }
  });

  group('PriceController Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final assetSchema = AssetConfigSchema();
    final priceSchema = IndexPriceSchema();
    const cacheTYpe = CacheKeyType.memoryCache;
    const keepAlive = true;
    final testAsset = AssetConfig(
      id: 1,
      symbol: "SAP",
      currency: FiatEur(),
      stockExchange: StockExchange.xEtra,
    );

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: cacheTYpe.key);
      await dbHelper.init();
      // Setup tables
      await dbHelper.createCache(assetSchema);
      await dbHelper.createCache(priceSchema);
      await dbHelper.saveOne(assetSchema, testAsset);

      container = ProviderContainer.test(
        overrides: [
          loadPriceProvider(cacheTYpe, keepAlive).overrideWith((ref) => dbHelper),
          sortedAssetsProvider.overrideWith((ref) => [testAsset]),
        ],
      );
      
      // Ensure provider is initialized and database is ready
      await container.read(loadPriceProvider(cacheTYpe, keepAlive).future);
      
      container.listen(priceControllerProvider(cacheTYpe, keepAlive), (_, _) {});
    });

    tearDown(() {
      dbHelper.dispose();
      container.dispose();
    });

    test('Initial state is empty', () {
      final state = container.read(priceControllerProvider(cacheTYpe, keepAlive));
      expect(state.cache, isEmpty);
      // assetDetails should be empty initially unless refreshAllDetails is called
      expect(state.assetDetails, isEmpty);
    });

    test('save and fetchAll', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final price = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 105.0,
        highPrice: 110.0,
        lowPrice: 95.0,
        volume: 1000.0,
      );

      await controller.save(priceSchema, price);
      final items = await controller.fetchAll(priceSchema);

      expect(items.length, 1);
      expect(items.first.assetId, testAsset.id);
      expect(items.first.closePrice, 105.0);
    });

    test('fetchDateRange', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final p1 = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 2),
        openPrice: 100.0,
        closePrice: 101.0,
        highPrice: 102.0,
        lowPrice: 99.0,
        volume: 800.0,
      );

      final p2 = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 5),
        openPrice: 105.0,
        closePrice: 106.0,
        highPrice: 107.0,
        lowPrice: 104.0,
        volume: 1100.0,
      );

      await controller.save(priceSchema, p1);
      await controller.save(priceSchema, p2);

      final range = await controller.fetchDateRange(
        priceSchema,
        testAsset,
        DateTime(2023, 1, 4),
        DateTime(2023, 1, 5),
      );

      expect(range.length, 1);
      expect(range.first.dateTime.day, 5);
    });

    test('update price', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      // Save initial price first to ensure we have something to update
      final price = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 105.0,
        highPrice: 110.0,
        lowPrice: 95.0,
        volume: 1000.0,
      );
      await controller.save(priceSchema, price);
      
      final savedItems = await controller.fetchAll(priceSchema);
      final savedPrice = savedItems.first;

      final updatedPrice = IndexPrice(
        id: savedPrice.id,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 115.0,
        highPrice: 120.0,
        lowPrice: 95.0,
        volume: 2000.0,
      );

      await controller.update(priceSchema, updatedPrice);
      final updatedItems = await controller.fetchAll(priceSchema);

      expect(updatedItems.firstWhere((elem) => elem.id == updatedPrice.id).closePrice, updatedPrice.closePrice);
      expect(updatedItems.firstWhere((elem) => elem.id == updatedPrice.id).volume, updatedPrice.volume);
    });

    test('delete price', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final price = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 105.0,
        highPrice: 110.0,
        lowPrice: 95.0,
        volume: 1000.0,
      );

      await controller.save(priceSchema, price);
      var items = await controller.fetchAll(priceSchema);
      expect(items.length, 1);

      await controller.delete(priceSchema, items.first);
      items = await controller.fetchAll(priceSchema);
      expect(items, isEmpty);
    });

    test('oldestDate and newestDate', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final p1 = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 101.0,
        highPrice: 102.0,
        lowPrice: 99.0,
        volume: 1000.0,
      );
      final p2 = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 2, 1),
        openPrice: 105.0,
        closePrice: 106.0,
        highPrice: 107.0,
        lowPrice: 104.0,
        volume: 1100.0,
      );

      await controller.save(priceSchema, p1);
      await controller.save(priceSchema, p2);

      final oldest = await controller.oldestDate(priceSchema, testAsset);
      final newest = await controller.newestDate(priceSchema, testAsset);

      expect(oldest.year, 2023);
      expect(oldest.month, 1);
      expect(newest.year, 2023);
      expect(newest.month, 2);
    });

    test('assetPriceDetails updates after refreshAllDetails', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final price = IndexPrice(
        id: 0,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 105.0,
        highPrice: 110.0,
        lowPrice: 95.0,
        volume: 1000.0,
      );

      await controller.save(priceSchema, price);
      await controller.refreshAllDetails();
      
      // final details = container.read(assetPriceDetailsProvider);
      final details = container.read(assetPriceDetailsProvider(cacheTYpe, keepAlive));
      expect(details.containsKey(testAsset.id), isTrue);
      expect(details[testAsset.id], contains('2023-01-01'));
    });
  });
}
