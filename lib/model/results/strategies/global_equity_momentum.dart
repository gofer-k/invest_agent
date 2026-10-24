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

// TODO: This move to extended asset config
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
  final Set<AssetConfig> supportingAssets;

  GemAsset({required this.type, required this.asset, required this.supportingAssets});

  GemAsset copyWith({GemAssetType? newType, AssetConfig? newAsset, Set<AssetConfig>? newSupportingAssets}) {
    return GemAsset(
      type: newType ?? type,
      asset: newAsset ?? asset,
      supportingAssets: newSupportingAssets ?? supportingAssets);
  }

  factory GemAsset.fromMap(Map<String, dynamic> params) {
    final assetType = GemAssetType.values.firstWhere(
      (e) => e.name == params['asset-type'],
      orElse: () => GemAssetType.equity
    );

    final mainAssetId = params['main-asset-id'] as int;
    final balanceAssetsRaw = params['balance-assets'] as List<dynamic>;
    final balanceAssets = balanceAssetsRaw.cast<int>();

    final mainAsset = AssetConfig.of(id: mainAssetId);
    final supportingAssets = balanceAssets.map((e) => AssetConfig.of(id: e)).toSet();
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
      const SetEquality().equals(supportingAssets, other.supportingAssets));

  @override
  int get hashCode => Object.hash(asset, type, const SetEquality().hash(supportingAssets),);

  List<Object?> get props => [type, asset, supportingAssets];

  @override
  String toString() => "gen_asset_type: ${type.name}, asset: ${asset.toDetailString()}, supporting assets: ${supportingAssets.map((e) => e.toDetailString()).join(', ')}";
}

class GemStrategyConfig extends Strategy {
  final GemAsset mainAsset;
  final GemAsset momentumAsset;
  final double inflation;
  final int absoluteMomentumInterval;
  final int relativeMomentumInterval;

  static const double defaultInflation = 0.0;
  static const int defaultIntervalInMonth = 12;

  GemStrategyConfig({
    required super.id,
    required super.type,
    required super.name,
    required this.mainAsset,
    required this.momentumAsset,
    this.inflation = defaultInflation,
    this.absoluteMomentumInterval = defaultIntervalInMonth,
    this.relativeMomentumInterval = defaultIntervalInMonth,
  });

  CacheUniqueKey get uniqueKey {
    return "$name-$type-$inflation-$absoluteMomentumInterval-$relativeMomentumInterval-${mainAsset.toString()} ${momentumAsset.toString()}".hashCode;
  }

  @override
  Strategy fillAssets(List<AssetConfig> assets) {
    if (assets.isEmpty) return this;

    AssetConfig find(AssetConfig original) =>
        assets.firstWhere((a) => a.id == original.id, orElse: () => original);

    return copyWith(
      newMainAsset: mainAsset.copyWith(
        newAsset: find(mainAsset.asset),
        newSupportingAssets: mainAsset.supportingAssets.map(find).toSet()
      ),
      newMomentumAsset: momentumAsset.copyWith(
        newAsset: find(momentumAsset.asset),
        newSupportingAssets: momentumAsset.supportingAssets.map(find).toSet()
      )
    );
  }

  factory GemStrategyConfig.emptyStrategy() {
    return GemStrategyConfig(
      id: Strategy.defaultId,
      type: StrategyType.gem,
      name: '',
      inflation: defaultInflation,
      absoluteMomentumInterval: defaultIntervalInMonth,
      relativeMomentumInterval: defaultIntervalInMonth,
      mainAsset: GemAsset(
        type: GemAssetType.equity, asset: AssetConfig.defaultAsset(),
        supportingAssets: {}),
      momentumAsset: GemAsset(
        type: GemAssetType.bond, asset: AssetConfig.defaultAsset(),
        supportingAssets: {}),
    );
  }

  @override
  Strategy copyWith({int? newId, String? newName,
    StrategyType? newType,
    GemAsset? newMainAsset,
    GemAsset? newMomentumAsset,
    double? newInflation,
    int? newAbsoluteMomentumInMonth,
    int? newRelativeMomentumInMonth,
  }) {

    return GemStrategyConfig(
      id: newId ?? id,
      name: newName ?? name,
      type: newType ?? type,
      mainAsset: newMainAsset ?? mainAsset,
      momentumAsset: newMomentumAsset ?? momentumAsset,
      inflation: newInflation ?? inflation,
      absoluteMomentumInterval: newAbsoluteMomentumInMonth ?? absoluteMomentumInterval,
      relativeMomentumInterval: newRelativeMomentumInMonth ?? relativeMomentumInterval,
    );
  }

  @override
  factory GemStrategyConfig.fromMap(int id, String name,
    Map<String, dynamic> params) {

    final jsonMainAsset = params['main-asset'] as Map<String, dynamic>;
    final jsonMomentumAsset = params['momentum-assets'] as Map<String, dynamic>;
    final jsonInflation = params['inflation'] as double;
    final jsonRebalanceIntervalInMonth = params['absolute-momentum'] as int;
    final jsonRelativeRebalanceIntervalInMonth = params['relative-momentum'] as int;

    return GemStrategyConfig(id: id, type: StrategyType.gem, name: name,
      mainAsset: GemAsset.fromMap(jsonMainAsset),
      momentumAsset: GemAsset.fromMap(jsonMomentumAsset),
      inflation: jsonInflation,
      absoluteMomentumInterval: jsonRebalanceIntervalInMonth,
      relativeMomentumInterval: jsonRelativeRebalanceIntervalInMonth,
    );
  }

  factory GemStrategyConfig.fromStrategy(Strategy strategy) {
    return GemStrategyConfig(
      id: strategy.id,
      name: strategy.name,
      type: StrategyType.gem,
      mainAsset: GemAsset(
        type: GemAssetType.equity, asset: AssetConfig.defaultAsset(),
        supportingAssets: {}),
      momentumAsset: GemAsset(
        type: GemAssetType.bond, asset: AssetConfig.defaultAsset(),
        supportingAssets: {}),
      inflation: defaultInflation,
      absoluteMomentumInterval: defaultIntervalInMonth,
      relativeMomentumInterval: defaultIntervalInMonth,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    "inflation": inflation,
    "absolute-momentum": absoluteMomentumInterval,
    "relative-momentum": relativeMomentumInterval,
    "main-asset": mainAsset.toMap(),
    "momentum-assets": momentumAsset.toMap()
  };

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is GemStrategyConfig &&
      runtimeType == other.runtimeType &&
      super == other &&
      absoluteMomentumInterval == other.absoluteMomentumInterval &&
      relativeMomentumInterval == other.relativeMomentumInterval &&
      inflation == other.inflation &&
      mainAsset == other.mainAsset &&
      momentumAsset == other.momentumAsset);

  @override
  int get hashCode => Object.hash(
      super.hashCode,
      inflation,
      absoluteMomentumInterval,
      relativeMomentumInterval,
      mainAsset,
      momentumAsset,);

  @override
  List<Object?> get props => [...super.props, inflation, absoluteMomentumInterval, relativeMomentumInterval, mainAsset, momentumAsset];
}
