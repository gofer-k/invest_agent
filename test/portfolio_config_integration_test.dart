import 'package:test/test.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_config.dart';
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
        metaIds: [1],
        targetWeight: 0.1,
        rebalanceThreshold: 0.05);
      await dbHelper.saveOne<PortfolioConfig>(schema, config);
      final fetchingResult = await dbHelper.fetchOne<PortfolioConfig>(schema, config);
      expect(fetchingResult, isNotNull);
      expect(fetchingResult?.id, equals(1));
      expect(fetchingResult?.portfolioName, equals("New portfolio"));
      expect(fetchingResult?.targetWeight, closeTo(0.1, 0.001));
      expect(fetchingResult?.rebalanceThreshold, closeTo(0.05, 0.0005));
      expect(fetchingResult?.metaIds, isNotEmpty);
      expect(fetchingResult?.metaIds, equals([1]));
    });

    test('fetchAll() generates SQL that actually finds all the records', () async {
      final portfolios = [
        PortfolioConfig(id: 1,
            portfolioName: "Portfolio 1",
            metaIds: [1],
            targetWeight: 0.1,
            rebalanceThreshold: 0.05),
        PortfolioConfig(id: 2,
            portfolioName: "Portfolio 2",
            metaIds: [2],
            targetWeight: 0.2,
            rebalanceThreshold: 0.1)
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
        expect(resItem.targetWeight, closeTo(resultConfig.targetWeight, 0.001));
        expect(resItem.rebalanceThreshold,
            closeTo(resultConfig.rebalanceThreshold, 0.0001));
        expect(resItem.metaIds, equals(resultConfig.metaIds));
      }
    });

    test('deleteOne() generates SQL that actually deletes the record', () async {
      final portfolio = PortfolioConfig(id: 1,
        portfolioName: "Portfolio 1",
        metaIds: [1],
        targetWeight: 0.1,
        rebalanceThreshold: 0.05);
      await dbHelper.saveOne(schema, portfolio);
      await dbHelper.deleteOne(schema, portfolio);
      final result = await dbHelper.fetchOne(schema, portfolio);
      expect(result, isNull);
    });

    test('updateOne() generates SQL that actually updates the record', () async {
      final origin = PortfolioConfig(id: 1,
          portfolioName: "Portfolio 1",
          metaIds: [1],
          targetWeight: 0.1,
          rebalanceThreshold: 0.05);
      final updated = PortfolioConfig(id: 1,
          portfolioName: "Portfolio 1",
          metaIds: [2],
          targetWeight: 0.2,
          rebalanceThreshold: 0.1);
      await dbHelper.saveOne(schema, origin);
      await dbHelper.updateOne(schema, updated);
      final result = await dbHelper.fetchOne(schema, origin);
      expect(result, isNotNull);
      expect(result?.id, equals(1));
      expect(result?.portfolioName, equals("Portfolio 1"));
      expect(result?.targetWeight, closeTo(0.2, 0.0001));
      expect(result?.rebalanceThreshold, closeTo(0.1, 0.0001));
      expect(result?.metaIds, equals([2]));
    });
  });
}