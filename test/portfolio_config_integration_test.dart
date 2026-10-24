import 'package:test/test.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

void main() {
  group("PortfolioConfig Integration Tests", () {
    late DatabaseHelper dbHelper;
    final schema = PortfolioConfigSchema();
    final assetSchema = AssetConfigSchema();
    late List<AssetConfig> assets;

    setUp(() async {
      dbHelper = DatabaseHelper(cacheFile: ":memory:");
      await dbHelper.init();
      await dbHelper.createCache(schema);
      await dbHelper.createCache(assetSchema);

      assets = [
        AssetConfig(id: 1, symbol: 'ISAC', currency: FiatCurrency.usd(),
            stockExchange: StockExchange.lSe),
        AssetConfig(id: 2, symbol: 'SAP', currency: FiatCurrency.eur(),
            stockExchange: StockExchange.xEtra)
      ];
      await dbHelper.saveAll<AssetConfig>(assetSchema, assets);
    });

    tearDown(() {
      dbHelper.dispose();
    });

    test('should save and retrieve a PortfolioConfig', () async {
      final config = PortfolioConfig(
        id: 1,
        portfolioName: "New portfolio",
        riskFreeRatePerYear: 0.1,
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2025, 1, 1),
      );
      await dbHelper.saveOne<PortfolioConfig>(schema, config);
      final fetchingResult = await dbHelper.fetchOne<PortfolioConfig>(schema, config);
      expect(fetchingResult, isNotNull);
      expect(fetchingResult?.id, equals(1));
      expect(fetchingResult?.portfolioName, equals("New portfolio"));
      expect(fetchingResult?.riskFreeRatePerYear, equals(0.1));
    });

    test('fetchAll() generates SQL that actually finds all the records', () async {
      final portfolios = [
        PortfolioConfig(id: 1,
          portfolioName: "Portfolio 1",
          riskFreeRatePerYear: 0.1,
          startDateTime: DateTime(2023, 1, 1),
          endDateTime: DateTime(2025, 1, 1),
        ),
        PortfolioConfig(id: 2,
          portfolioName: "Portfolio 2",
          riskFreeRatePerYear: 0.1,
          startDateTime: DateTime(2023, 1, 1),
          endDateTime: DateTime(2025, 1, 1),
        )
      ];
      await dbHelper.saveAll(schema, portfolios);
      final result = await dbHelper.fetchAll<PortfolioConfig>(schema);
      expect(result, isNotEmpty);
      expect(result.length, equals(2));
      for (final resItem in result) {
        final resultConfig = portfolios.firstWhere((item) =>
        item.id == resItem.id);
        expect(resItem.id, equals(resultConfig.id));
        expect(resItem.portfolioName, equals(resultConfig.portfolioName));
        expect(resItem.riskFreeRatePerYear,
            closeTo(resultConfig.riskFreeRatePerYear, 0.0001));
      }
    });

    test('deleteOne() generates SQL that actually deletes the record', () async {
      final portfolio = PortfolioConfig(id: 1,
        portfolioName: "Portfolio 1",
        riskFreeRatePerYear: 0.1,
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2025, 1, 1),
      );
      await dbHelper.saveOne(schema, portfolio);
      await dbHelper.deleteOne(schema, portfolio);
      final result = await dbHelper.fetchOne(schema, portfolio);
      expect(result, isNull);
    });

    test('updateOne() generates SQL that actually updates the record', () async {
      final origin = PortfolioConfig(id: 1,
        portfolioName: "Portfolio 1",
        riskFreeRatePerYear: 0.1,
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2025, 1, 1),
      );
      final updated = PortfolioConfig(id: 1,
        portfolioName: "Portfolio 1",
        riskFreeRatePerYear: 0.2,
        startDateTime: DateTime(2023, 1, 1),
        endDateTime: DateTime(2025, 1, 1),
      );
      await dbHelper.saveOne(schema, origin);
      await dbHelper.updateOne(schema, updated);
      final result = await dbHelper.fetchOne(schema, origin);
      expect(result, isNotNull);
      expect(result?.id, equals(1));
      expect(result?.portfolioName, equals("Portfolio 1"));
      expect(result?.riskFreeRatePerYear, closeTo(0.2, 0.0001));
    });
  });
}