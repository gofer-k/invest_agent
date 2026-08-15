import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';

import '../../cache_schema.dart';

class MeanReversionConfig extends Strategy {
  final AssetConfig asset;
  final Indicator indicator;

  MeanReversionConfig({
    super.type = StrategyType.meanReversion,
    super.parameters = const {},
    required super.id,
    required super.name,
    required this.asset,
    required this.indicator});

  CacheUniqueKey get uniqueKey {
    return "$name-$type--${asset.toDetailString()} ${indicator.uniqueKey}".hashCode;
  }

  factory MeanReversionConfig.emptyStrategy() {
    return MeanReversionConfig(
      id: Strategy.defaultId,
      asset: AssetConfig.defaultAsset(),
      type: StrategyType.meanReversion,
      indicator: Indicator.emptyIndicator(),
      name: '');
  }

  /*
  {
    "asset": 20,
    "indicator": [
      {
        "sma": {
          "window": {
            "value": "50",
            "edit": "1",
            "type": "int",
            "visible": "1"
          },
          "chart": {
            "value": "#FF34BBE6",
            "edit": "1",
            "type": "color",
            "visible": "1"
          },
          "golden_cross": {
            "value": "#FFF7D038",
            "edit": "1",
            "type": "color",
            "visible": "0"
          },
          "death_cross": {
            "value": "#FFE6261F",
            "edit": "1",
            "type": "color",
            "visible": "0"
          }
        }
      }
    ]
  }
   */
  @override
  factory MeanReversionConfig.fromMap(int id, String name, Map<String, dynamic> params) {
    // 1. Safely handle the Asset
    final assetId = params['asset'] as int? ?? 0;

    // 2. Safely handle the Indicator List
    final List<dynamic> indicatorList = params['indicator'] ?? [];

    Indicator indicator;
    if (indicatorList.isNotEmpty) {
      // Access the first element safely
      final Map<dynamic, dynamic> firstEntry = indicatorList.first ?? {};

      if (firstEntry.isNotEmpty) {
        // The key is the indicator type (e.g., 'sma')
        final String typeStr = firstEntry.keys.first.toString();

        // Use safe casting or 'Map.from' to avoid Type errors
        final Map<String, dynamic> innerParams = Map<String, dynamic>.from(firstEntry[typeStr] ?? {});

        indicator = Indicator(
          id: 0, // Or extract if available
          name: typeStr.toUpperCase(),
          type: IndicatorType.values.firstWhere(
                  (e) => e.name == typeStr,
              orElse: () => IndicatorType.undefined
          ),
          parameters: innerParams,
        );
      } else {
        indicator = Indicator.emptyIndicator();
      }
    } else {
      indicator = Indicator.emptyIndicator();
    }

    return MeanReversionConfig(
      id: id,
      name: name,
      asset: AssetConfig.of(id: assetId),
      indicator: indicator,
    );
  }

  @override
  MeanReversionConfig copyWith({
    int? newId,
    String? newName,
    StrategyType? newType,
    AssetConfig? newAsset,
    Indicator? newIndicator,
    Map<String, dynamic>? newParameters}) {
    return MeanReversionConfig(
        id: newId ?? id,
        asset: newAsset ?? asset,
        type: StrategyType.meanReversion,
        indicator: newIndicator ?? indicator,
        name: newName ?? name);
  }

  @override
  Map<String, dynamic> toMap() => {
    "asset": asset.id,
    "indicator": indicator.parameters.isNotEmpty
      ? [{indicator.type.shortName.toLowerCase(): indicator.parameters}]
      : []
  };

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is MeanReversionConfig &&
      runtimeType == other.runtimeType &&
      asset == other.asset &&
      indicator == other.indicator &&
      super.id == other.id &&
      super.type == other.type &&
      super.name == other.name);

  @override
  int get hashCode => super.hashCode ^ asset.hashCode ^ indicator.hashCode;

  @override
  List<Object?> get props => [super.props, asset, indicator];
}