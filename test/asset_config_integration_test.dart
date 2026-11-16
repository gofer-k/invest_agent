import 'package:test/test.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

void main() {
  group('AssetConfig Integration Tests', () {
    late DatabaseHelper dbHelper;
    final schema = AssetConfigSchema();

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: ":memory:");
      await dbHelper.init();
      await dbHelper.createCache(schema);
    });

    tearDown(() {
      dbHelper.dispose();
    });

    test('should save and retrieve an AssetConfig', () async {
      final config = AssetConfig(
        id: 1,
        symbol: "SAP",
        currency: FiatEur(),
        stockExchange: StockExchange.xEtra,
      );

      // Act: Insert using your generated SQL
      // Assuming your model has a method to get insert SQL or value
      await dbHelper.saveOne<AssetConfig>(schema, config);
      final fetchingResult = await dbHelper.fetchOne<AssetConfig>(schema, config);
      expect(fetchingResult, isNotNull);
      expect(fetchingResult?.id, equals(1));
      expect(fetchingResult?.symbol, equals("SAP"));
      expect(fetchingResult?.currency, equals(FiatEur()));
      expect(fetchingResult?.stockExchange, equals(StockExchange.xEtra));
    });

    test('fetchAll() generates SQL that actually finds all the records', () async {
      final configs = [
        AssetConfig(
          id: 1,
          symbol: "SAP",
          currency: FiatEur(),
          stockExchange: StockExchange.xEtra),
        AssetConfig(
          id: 2,
          symbol: "ISAC",
          currency: FiatUsd(),
          stockExchange: StockExchange.lSe)
      ];
      await dbHelper.saveAll<AssetConfig>(schema, configs);
      final result = await dbHelper.fetchAll<AssetConfig>(schema);
      expect(result, isNotEmpty);
      expect(result.length, equals(2));

      for (final resItem in result) {
        final resultConfig = configs.firstWhere((item) => item.id == resItem.id);
        expect(resItem.id, equals(resultConfig.id));
        expect(resItem.symbol, equals(resultConfig.symbol));
        expect(resItem.currency, equals(resultConfig.currency));
        expect(resItem.stockExchange, equals(resultConfig.stockExchange));
      }
    });

    test('deleteOne() generates SQL that actually deletes the record', () async {
      final config = AssetConfig(
          id: 1,
          symbol: "SAP",
          currency: FiatEur(),
          stockExchange: StockExchange.xEtra);
      await dbHelper.saveOne<AssetConfig>(schema, config);
      await dbHelper.deleteOne<AssetConfig>(schema, config);
      final result = await dbHelper.fetchOne<AssetConfig>(schema, config);
      expect(result, isNull);
    });

    test('updateOne() generates SQL that actually updates the record', () async {
      final originC = AssetConfig(
          id: 1,
          symbol: "SAP",
          currency: FiatEur(),
          stockExchange: StockExchange.xEtra);
      await dbHelper.saveOne<AssetConfig>(schema, originC);

      final updated = AssetConfig(
          id: 1,
          symbol: "ISAC",
          currency: FiatEur(),
          stockExchange: StockExchange.xEtra);
      await dbHelper.updateOne<AssetConfig>(schema, updated);
      final result = await dbHelper.fetchOne<AssetConfig>(schema, originC);
      expect(result, isNotNull);
      expect(result?.id, equals(1));
      expect(result?.symbol, equals("ISAC"));
    });
  });
}