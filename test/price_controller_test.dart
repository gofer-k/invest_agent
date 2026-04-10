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
      final ldPath = Platform.environment['LD_DUCKDB_PATH'];
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
        DynamicLibrary.open('libduckdb.so');
      }
    } catch (e) {
      // It might already be loaded or fail if not found anywhere
      print('Library load info: $e');
    }
  });

  group('PriceController Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final assetSchema = AssetConfigSchema();
    final priceSchema = IndexPriceSchema();

    final testAsset = AssetConfig(
      id: 1,
      symbol: "SAP",
      currency: FiatEur(),
      stockExchange: StockExchange.xEtra,
    );

    setUp(() async {
      dbHelper = DatabaseHelper(":memory:");
      await dbHelper.init();
      // Setup tables
      await dbHelper.createCache(assetSchema);
      await dbHelper.createCache(priceSchema);
      await dbHelper.saveOne(assetSchema, testAsset);

      container = ProviderContainer.test(
        // Mock test caches and database
        overrides: [
          databaseHelperProvider.overrideWith((ref) => dbHelper),
          useAssetsProvider.overrideWith((ref) => [testAsset]),
          assetPriceDetailsProvider.overrideWith((ref) => {testAsset.id: testAsset.symbol}),
        ],
      );
      // Keep the provider alive during the test.
      container.listen(priceControllerProvider, (_, __) {});
      container.listen(assetPriceDetailsProvider, (_, __) {});
    });

    tearDown(() {
      dbHelper.dispose();
      container.dispose();
    });

    test('Initial state is empty', () {
      final state = container.read(priceControllerProvider);
      expect(state.cache, isEmpty);
      expect(state.assetDetails, isEmpty);
    });

    test('save and fetchAll', () async {
      final controller = await container.read(priceControllerProvider.notifier);
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

      final details = await container.read(useAssetsProvider);
      expect(details.firstWhere((asset) => asset.id == testAsset.id) == testAsset, isTrue);

      await controller.save(priceSchema, price);
      final items = await controller.fetchAll(priceSchema);

      expect(items.length, 1);
      expect(items.first.assetId, testAsset.id);
      expect(items.first.closePrice, 105.0);
    });

    test('fetchDateRange', () async {
      final controller = container.read(priceControllerProvider.notifier);
      final p1 = IndexPrice(
        id: 1,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 2),
        openPrice: 100.0,
        closePrice: 101.0,
        highPrice: 102.0,
        lowPrice: 99.0,
        volume: 000.0,
      );

      final p2 = IndexPrice(
      id: 2,
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
      final controller = container.read(priceControllerProvider.notifier);
      final price = IndexPrice(
        id: 1,
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
      final updatedPrice = IndexPrice(
        id: 1,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 115.0, // updated
        highPrice: 120.0,
        lowPrice: 95.0,
        volume: 2000.0,
      );

      await controller.update(priceSchema, updatedPrice);
      items = await controller.fetchAll(priceSchema);

      expect(items.first.closePrice, 115.0);
      expect(items.first.volume, 2000.0);
    });

    test('delete price', () async {
      final controller = container.read(priceControllerProvider.notifier);
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
      final controller = container.read(priceControllerProvider.notifier);
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
      expect(newest.month, 2);
    });

    test('assetPriceDetails updates after save', () async {
      final controller = container.read(priceControllerProvider.notifier);
      final price = IndexPrice(
        id: 1,
        assetId: testAsset.id,
        dateTime: DateTime(2023, 1, 1),
        openPrice: 100.0,
        closePrice: 105.0,
        highPrice: 110.0,
        lowPrice: 95.0,
        volume: 1000.0,
      );

      await controller.save(priceSchema, price);
      final details = await container.read(assetPriceDetailsProvider);
      expect(details.containsKey(testAsset.id), isTrue);
      expect(details[testAsset.id], contains(testAsset.symbol));
    });
  });
}
