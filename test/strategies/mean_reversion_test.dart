import 'package:flutter_test/flutter_test.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/results/strategies/mean_reversion.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';

void main() {
  group('MeanReversionConfig Tests', () {
    test('should create an empty strategy with default values', () {
      final strategy = MeanReversionConfig.emptyStrategy();

      expect(strategy.id, equals(Strategy.defaultId));
      expect(strategy.type, equals(StrategyType.meanReversion));
      expect(strategy.name, isEmpty);
      expect(strategy.indicator.type, equals(IndicatorType.undefined));
    });

    test('should correctly instantiate fromMap', () {
      final params = {
        "asset": 20,
        "indicator": [
          {
            "sma": {
              "window": {"value": "50", "type": "int"}
            }
          }
        ]
      };

      final strategy = MeanReversionConfig.fromMap(1, "Test Strategy", params);

      expect(strategy.id, 1);
      expect(strategy.name, "Test Strategy");
      expect(strategy.asset.id, 20);
      expect(strategy.indicator.type, IndicatorType.sma);
      expect(strategy.indicator.parameters['window']['value'], "50");
    });

    test('should return correct map from toMap()', () {
      final indicator = Indicator(
          id: 1,
          name: 'sma',
          type: IndicatorType.sma,
          parameters: {"window": {"value": "20"}}
      );

      final strategy = MeanReversionConfig(
        id: 1,
        name: "Test",
        asset: AssetConfig.of(id: 10),
        indicator: indicator,
      );

      final map = strategy.toMap();

      expect(map['asset'], 10);
      final indicatorMap = map['indicator'][0];
      expect(map['indicator'], isA<List>());
      expect(indicatorMap.containsKey('sma'), true);
      expect(indicatorMap['sma']['window']['value'], "20");
    });

    test('copyWith should return a new object with updated values', () {
      final original = MeanReversionConfig.emptyStrategy();
      final newAsset = AssetConfig.of(id: 99);

      final updated = original.copyWith(
        newName: "Updated Name",
        newAsset: newAsset,
      );

      expect(updated.name, "Updated Name");
      expect(updated.asset.id, 99);
      expect(updated.id, original.id); // Should remain same if not provided
      expect(updated.indicator, original.indicator);
    });

    test('equality and hashCode should work', () {
      final asset = AssetConfig.of(id: 1);
      final indicator = Indicator.emptyIndicator();

      final strategy1 = MeanReversionConfig(
        id: 1,
        name: "S1",
        asset: asset,
        indicator: indicator,
      );

      final strategy2 = MeanReversionConfig(
        id: 1,
        name: "S1",
        asset: asset,
        indicator: indicator,
      );

      final strategy3 = MeanReversionConfig(
        id: 2,
        name: "S1",
        asset: asset,
        indicator: indicator,
      );

      expect(strategy1, equals(strategy2));
      expect(strategy1.hashCode, equals(strategy2.hashCode));
      expect(strategy1, isNot(equals(strategy3)));
    });

    test('uniqueKey should be consistent for same configuration', () {
      final strategy1 = MeanReversionConfig.emptyStrategy();
      final strategy2 = MeanReversionConfig.emptyStrategy();

      expect(strategy1.uniqueKey, equals(strategy2.uniqueKey));
    });
  });
}