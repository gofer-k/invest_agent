import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/price_result.dart';
import 'package:invest_agent/providers/assets_utilities.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/price_controller.dart';
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
        DynamicLibrary.open('$homePath/.pub-cache/hosted/pub.dev/dart_duckdb-1.4.4/linux/Libraries/release/libduckdb.so');
      }
    } catch (e) {
      exit(-1);
    }
  });

  group('assetsByTimeSpanProvider Tests', () {
    late ProviderContainer container;
    late DatabaseHelper dbHelper;
    final assetSchema = AssetConfigSchema();
    final priceSchema = IndexPriceSchema();
    const keepAlive = true;
    const cacheTYpe = CacheKeyType.memoryCache;

    final asset1 = AssetConfig(
      id: 1,
      symbol: "SAP",
      currency: FiatEur(),
      stockExchange: StockExchange.xEtra,
    );

    final asset2 = AssetConfig(
      id: 2,
      symbol: "AAPL",
      currency: FiatUsd(),
      stockExchange: StockExchange.lSe,
    );

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: cacheTYpe.key);
      await dbHelper.init();
      await dbHelper.createCache(assetSchema);
      await dbHelper.createCache(priceSchema);
      await dbHelper.saveOne(assetSchema, asset1);
      await dbHelper.saveOne(assetSchema, asset2);

      container = ProviderContainer(
        overrides: [
          loadPriceProvider(cacheTYpe, keepAlive).overrideWith((ref) => dbHelper),
          appConfigProvider.overrideWith((ref) => dbHelper),
        ],
      );
      await container.read(loadPriceProvider(cacheTYpe, keepAlive).future);
      // Keep the provider alive during the test.
      container.listen(priceControllerProvider(cacheTYpe, keepAlive), (_, _) {});
    });

    tearDown(() {
      dbHelper.dispose();
      container.dispose();
    });

    test('groups assets by the same time span', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 1, 10);

      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset1.id, dateTime: date1,
        openPrice: 100, closePrice: 100, highPrice: 100, lowPrice: 100, volume: 100
      ));
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset1.id, dateTime: date2,
        openPrice: 110, closePrice: 110, highPrice: 110, lowPrice: 110, volume: 100
      ));

      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset2.id, dateTime: date1,
        openPrice: 150, closePrice: 150, highPrice: 150, lowPrice: 150, volume: 100
      ));
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset2.id, dateTime: date2,
        openPrice: 160, closePrice: 160, highPrice: 160, lowPrice: 160, volume: 100
      ));

      final result = await container.read(assetsByTimeSpanProvider([asset1, asset2], cacheTYpe, keepAlive).future);

      expect(result.length, 1);
      final range = DateTimeRange(start: DateUtils.dateOnly(date1), end: DateUtils.dateOnly(date2));
      expect(result.containsKey(range), isTrue);
      expect(result[range]!.length, 2);
      expect(result[range], containsAll([asset1, asset2]));
    });

    test('separates assets with different time spans', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 1, 10);
      final date3 = DateTime(2023, 1, 15);

      // Asset 1: date1 to date2
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset1.id, dateTime: date1,
        openPrice: 100, closePrice: 100, highPrice: 100, lowPrice: 100, volume: 100
      ));
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset1.id, dateTime: date2,
        openPrice: 110, closePrice: 110, highPrice: 110, lowPrice: 110, volume: 100
      ));

      // Asset 2: date1 to date3
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset2.id, dateTime: date1,
        openPrice: 150, closePrice: 150, highPrice: 150, lowPrice: 150, volume: 100
      ));
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset2.id, dateTime: date3,
        openPrice: 170, closePrice: 170, highPrice: 170, lowPrice: 170, volume: 100
      ));

      final result = await container.read(assetsByTimeSpanProvider([asset1, asset2], cacheTYpe, keepAlive).future);

      expect(result.length, 2);
      final range1 = DateTimeRange(start: DateUtils.dateOnly(date1), end: DateUtils.dateOnly(date2));
      final range2 = DateTimeRange(start: DateUtils.dateOnly(date1), end: DateUtils.dateOnly(date3));
      
      expect(result.containsKey(range1), isTrue);
      expect(result[range1], contains(asset1));
      
      expect(result.containsKey(range2), isTrue);
      expect(result[range2], contains(asset2));
    });

    test('filters out short time spans', () async {
      final controller = container.read(priceControllerProvider(cacheTYpe, keepAlive).notifier);
      
      final date1 = DateTime(2023, 1, 1, 12, 0, 0);
      // Same day, results in 0 duration after DateUtils.dateOnly
      
      await controller.save(priceSchema, IndexPriceItem(
        id: 0, assetId: asset1.id, dateTime: date1,
        openPrice: 100, closePrice: 100, highPrice: 100, lowPrice: 100, volume: 100
      ));

      final result = await container.read(assetsByTimeSpanProvider([asset1], cacheTYpe, keepAlive).future);

      expect(result, isEmpty);
    });
  });
}
