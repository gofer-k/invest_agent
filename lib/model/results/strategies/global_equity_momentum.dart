/*
{
  "risk": [
    {    
      "asset": 20,
      "main": 1,
      "indicator": [
        {
          "sma": {
            ....
          }
        }
      ]
    },
    {    
      "asset": 20,
      "main": 0,
      "indicator": [
        {
          "sma": {
            ...
          }
        }
      ]
    }
  ],
  "free-risk": [ 
  ...
  ]
}
 */

import 'package:collection/collection.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';

import '../../cache_schema.dart';

/*
Note: The assets' prices are use to compute this strategy.
    {
    "main-asset": {
      "asset-type": "equity",
      "main-asset-id": 20,
      "balance-assets": [
        20,
        21
      ]
    },
    "momentum-assets": {
      "asset-type": "bons",
      "main-asset-id": 2,
      "balance-assets": [
        3,
        4
      ]
    }
  }
   */
enum GemAssetType {
  bond("bonds"),
  commodity("commodity"),
  equity("equity"); // stock shares

  final String name;
  const GemAssetType(this.name);
}

class GemAsset {
  final GemAssetType type;
  final AssetConfig asset;
  final List<AssetConfig> supportingAssets;

  GemAsset({required this.type, required this.asset, required this.supportingAssets});

  factory GemAsset.fromMap(Map<String, dynamic> params) {
    final assetType = GemAssetType.values.firstWhere(
      (e) => e.name == params['asset-type'],
      orElse: () => GemAssetType.equity
    );
    final mainAssetId = params['main-asset-id'] as int;
    final balanceAssets = params['balance-assets'] as List<int>;
    final mainAsset = AssetConfig.of(id: mainAssetId);
    final supportingAssets = balanceAssets.map((e) => AssetConfig.of(id: e)).toList();
    return GemAsset(type: assetType, asset: mainAsset, supportingAssets: supportingAssets);
  }

  Map<String, dynamic> toMap() => {
    "asset-type": type.name,
    "main-asset-id": asset.id,
    "balance-assets": supportingAssets.map((e) => e.id).toList()};

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is GemAsset &&
      runtimeType == other.runtimeType &&
      type == other.type &&
      asset == other.asset &&
      const ListEquality().equals(supportingAssets, other.supportingAssets));

  @override
  int get hashCode => type.hashCode ^ asset.hashCode ^ const ListEquality().hash(supportingAssets);

  List<Object?> get props => [type, asset, supportingAssets];

  @override
  String toString() => "gen_asset_type: ${type.name}, asset: ${asset.toDetailString()}, supporting assets: ${supportingAssets.map((e) => e.toDetailString()).join(', ')}";
}

class GemStrategyConfig extends Strategy {
  final GemAsset mainAsset;
  final GemAsset momentumAsset;

  GemStrategyConfig({
    required super.id, required super.type, required super.name,
    required this.mainAsset, required this.momentumAsset});

  CacheUniqueKey get uniqueKey {
    return "$name-$type--${mainAsset.toString()} ${momentumAsset.toString()}".hashCode;
  }

  factory GemStrategyConfig.emptyStrategy() {
    return GemStrategyConfig(
      id: Strategy.defaultId,
      type: StrategyType.gem,
      name: '',
      mainAsset: GemAsset(
        type: GemAssetType.equity, asset: AssetConfig.defaultAsset(),
        supportingAssets: []),
      momentumAsset: GemAsset(
        type: GemAssetType.bond, asset: AssetConfig.defaultAsset(),
        supportingAssets: []));
  }

  @override
  Strategy copyWith({int? newId, String? newName,
    StrategyType? newType,
    Map<String, dynamic>? newParameters,
    GemAsset? newMainAsset,
    GemAsset? newMomentumAsset}) {

    return GemStrategyConfig(
      id: newId ?? id,
      name: newName ?? name,
      type: newType ?? type,
      mainAsset: newMainAsset ?? mainAsset,
      momentumAsset: newMomentumAsset ?? momentumAsset);
  }

  @override
  factory GemStrategyConfig.fromMap(int id, String name, Map<String, dynamic> params) {
    final jsonMainAsset = params['main-asset'] as Map<String, dynamic>;
    final jsonMomentumAsset = params['momentum-assets'] as Map<String, dynamic>;

    return GemStrategyConfig(id: id, type: StrategyType.gem, name: name,
        mainAsset: GemAsset.fromMap(jsonMainAsset),
        momentumAsset: GemAsset.fromMap(jsonMomentumAsset));
  }

  @override
  Map<String, dynamic> toMap() => {
    "main-asset": mainAsset.toMap(),
    "momentum-assets": momentumAsset.toMap()
  };

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is GemStrategyConfig &&
      runtimeType == other.runtimeType &&
      mainAsset == other.mainAsset &&
      momentumAsset == other.momentumAsset &&
      super.id == other.id &&
      super.type == other.type &&
      super.name == other.name
    );

  @override
  int get hashCode => super.hashCode ^ mainAsset.hashCode ^ momentumAsset.hashCode;

  @override
  List<Object?> get props => [mainAsset, momentumAsset];
}