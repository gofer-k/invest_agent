import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/providers/load_database_provider.dart';
import 'package:invest_agent/providers/price_importer_csv.dart';
import 'package:sealed_currencies/sealed_currencies.dart';
import 'package:test/test.dart';

void main() {
  group('PriceImporter Integration Tests', () {
    late ProviderContainer container;
    late Directory tempDir;
    final testAsset = AssetConfig(
      id: 1,
      symbol: "TEST_ASSET",
      currency: FiatUsd(),
      stockExchange: StockExchange.xWar,
    );
    File? csvFile;

    setUp(() async {
      // Create a temporary directory for test CSV files
      tempDir = await Directory.systemTemp.createTemp('price_importer_test');
      csvFile = File('${tempDir.path}/TEST_ASSET.csv');

      container = ProviderContainer(
        overrides: [],
      );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
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
