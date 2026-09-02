import 'package:flutter_test/flutter_test.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/results/strategies/global_equity_momentum.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

void main() {
  AssetConfig createMockAsset({required int id}) {
    // Assuming AssetConfig has a constructor similar to this based on usage
    return AssetConfig(id: id,
      symbol: 'SYM$id',
      currency: FiatCurrency.usd(),
      stockExchange: StockExchange.lSe);
  }

  group('GemAsset Tests', () {
    test('GemAsset.fromMap should create object correctly', () {
      final map = {
        "asset-type": "bonds",
        "main-asset-id": 2,
        "balance-assets": [3, 4]
      };

      final gemAsset = GemAsset.fromMap(map);

      expect(gemAsset.type, GemAssetType.bond);
      expect(gemAsset.asset.id, 2);
      expect(gemAsset.supportingAssets.length, 2);
      expect(gemAsset.supportingAssets.first.id, 3);
    });

    test('GemAsset.toMap should produce correct map', () {
      final gemAsset = GemAsset(
        type: GemAssetType.equity,
        asset: createMockAsset(id: 10),
        supportingAssets: {createMockAsset(id: 11)},
      );

      final map = gemAsset.toMap();

      expect(map["asset-type"], "equity");
      expect(map["main-asset-id"], 10);
      expect(map["balance-assets"], [11]);
    });
  });

  group('GemStrategy Tests', () {
    test('emptyStrategy should create a default instance', () {
      final strategy = GemStrategyConfig.emptyStrategy();

      expect(strategy.id, Strategy.defaultId);
      expect(strategy.type, StrategyType.gem);
      expect(strategy.name, isEmpty);
      expect(strategy.mainAsset.type, GemAssetType.equity);
      expect(strategy.momentumAsset.type, GemAssetType.bond);
    });

    test('should initialize GemStrategy with correct parameters', () {
      // Arrange
      final riskMain = createMockAsset(id: 20);
      final riskBalances = {createMockAsset(id: 21)};
      final safeMain = createMockAsset(id: 2);
      final safeBalances = {createMockAsset(id: 3), createMockAsset(id: 4)};

      final riskAsset = GemAsset(
        type: GemAssetType.equity,
        asset: riskMain,
        supportingAssets: riskBalances,
      );
      final safeAsset = GemAsset(
        type: GemAssetType.bond,
        asset: safeMain,
        supportingAssets: safeBalances,
      );

      const strategyId = 1;
      const strategyType = StrategyType.gem;
      const strategyName = 'Global Equity Momentum';

      // Act
      final strategy = GemStrategyConfig(
        id: strategyId,
        type: strategyType,
        name: strategyName,
        mainAsset: riskAsset,
        momentumAsset: safeAsset,
        cash: Strategy.defaultBudget,
        currency: Strategy.defaultCurrency,
        analysisPeriod: Strategy.defaultPeriod,
        beginDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      // Assert
      expect(strategy.id, strategyId);
      expect(strategy.type, strategyType);
      expect(strategy.name, strategyName);

      // Verify Risk Asset
      expect(strategy.mainAsset.type, GemAssetType.equity);
      expect(strategy.mainAsset.asset.id, 20);
      expect(strategy.mainAsset.supportingAssets.length, 1);

      // Verify Safe Asset
      expect(strategy.momentumAsset.type, GemAssetType.bond);
      expect(strategy.momentumAsset.asset.id, 2);
      expect(strategy.momentumAsset.supportingAssets.length, 2);
    });

    test('GemAssetType enum should return correct names', () {
      expect(GemAssetType.bond.name, "bonds");
      expect(GemAssetType.commodity.name, "commodity");
      expect(GemAssetType.equity.name, "equity");
    });

    test('fromMap should parse complex strategy JSON', () {
      const id = 101;
      const name = "My GEM Strategy";
      final params = {
        "cash": 10000.0,
        "currency": "pln",
        "analysisPeriod": "year",
        "beginDate": "2023-01-01",
        "endDate": "2023-12-31",
        "main-asset": {
          "asset-type": "equity",
          "main-asset-id": 20,
          "balance-assets": [20, 21]
        },
        "momentum-assets": {
          "asset-type": "bonds",
          "main-asset-id": 2,
          "balance-assets": [3, 4]
        }
      };

      final strategy = GemStrategyConfig.fromMap(id, name,
          Strategy.defaultBudget,
          Strategy.defaultCurrency,
          Strategy.defaultPeriod,
          DateTime.parse("2023-01-01"),
          DateTime.parse("2023-12-31"),
          params);

      expect(strategy.id, id);
      expect(strategy.name, name);
      expect(strategy.mainAsset.asset.id, 20);
      expect(strategy.momentumAsset.type, GemAssetType.bond);
      expect(strategy.momentumAsset.supportingAssets.length, 2);
    });

    test('copyWith should update only specified fields', () {
      final original = GemStrategyConfig.emptyStrategy();
      final newMainAsset = GemAsset(
        type: GemAssetType.commodity,
        asset: createMockAsset(id: 99),
        supportingAssets: {},
      );

      final updated = original.copyWith(
        newName: "Updated Name",
        newMainAsset: newMainAsset,
      ) as GemStrategyConfig;

      expect(updated.name, "Updated Name");
      expect(updated.mainAsset.type, GemAssetType.commodity);
      expect(updated.id, original.id); // Should remain same
      expect(updated.momentumAsset, original.momentumAsset); // Should remain same
    });

    test('uniqueKey should be consistent and change with data', () {
      final strategy1 = GemStrategyConfig.emptyStrategy().copyWith(newName: "Test") as GemStrategyConfig;
      final strategy2 = GemStrategyConfig.emptyStrategy().copyWith(newName: "Test") as GemStrategyConfig;
      final strategy3 = GemStrategyConfig.emptyStrategy().copyWith(newName: "Different") as GemStrategyConfig;

      expect(strategy1.uniqueKey, equals(strategy2.uniqueKey));
      expect(strategy1.uniqueKey, isNot(equals(strategy3.uniqueKey)));
    });

    test('Equality and HashCode deep validation', () {
      final s1 = GemStrategyConfig.emptyStrategy();
      final s2 = GemStrategyConfig.emptyStrategy();

      // 1. Verify basic properties
      expect(s1.id, s2.id);
      expect(s1.name, s2.name);
      expect(s1.type, s2.type);

      // 2. Verify Nested GemAsset Equality
      // We check properties individually in case GemAsset doesn't override == correctly
      expect(s1.mainAsset.type, s2.mainAsset.type);
      expect(s1.mainAsset.asset.id, s2.mainAsset.asset.id);
      expect(s1.mainAsset.supportingAssets.length, s2.mainAsset.supportingAssets.length);

      // 3. Verify Unique Key (The source of truth for your business logic)
      expect(s1.uniqueKey, s2.uniqueKey,
          reason: "uniqueKey must be identical for identical configurations");

      // 4. Final object equality check
      // This will only pass if you have overridden operator == in your classes
      expect(s1, equals(s2),
          reason: "GemStrategyConfig must implement value equality (check operator == and hashCode)");
      expect(s1.hashCode, s2.hashCode,
          reason: "Identical objects must have identical hashCodes");
    });

    test('uniqueKey should be consistent for same configuration', () {
      final strategy1 = GemStrategyConfig.emptyStrategy();
      final strategy2 = GemStrategyConfig.emptyStrategy();

      expect(strategy1.uniqueKey, equals(strategy2.uniqueKey));
    });
  });
}
