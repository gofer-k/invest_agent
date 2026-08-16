import 'package:collection/collection.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

import '../../cache_schema.dart';
import '../../period_type.dart';

/*
Note: The assets' prices are use to compute this strategy.
  {
    "cash"; 10000.0
    "currency|; "pln",
    "analysisPeriod"; "year",
    "beginDate"; "2023-01-01",
    "endDate|; "2023-12-31",
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
    final balanceAssetsRaw = params['balance-assets'] as List<dynamic>;
    final balanceAssets = balanceAssetsRaw.cast<int>();

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
  int get hashCode => Object.hash(asset, type, const ListEquality().hash(supportingAssets),);

  List<Object?> get props => [type, asset, supportingAssets];

  @override
  String toString() => "gen_asset_type: ${type.name}, asset: ${asset.toDetailString()}, supporting assets: ${supportingAssets.map((e) => e.toDetailString()).join(', ')}";
}

class GemStrategyConfig extends Strategy {
  final GemAsset mainAsset;
  final GemAsset momentumAsset;

  GemStrategyConfig({
    required super.id,
    required super.type,
    required super.name,
    required super.cash,
    required super.currency,
    required super.analysisPeriod,
    required super.beginDate,
    required super.endDate,
    required this.mainAsset,
    required this.momentumAsset});

  CacheUniqueKey get uniqueKey {
    return "$name-$type--${mainAsset.toString()} ${momentumAsset.toString()}".hashCode;
  }

  factory GemStrategyConfig.emptyStrategy() {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);

    return GemStrategyConfig(
      id: Strategy.defaultId,
      type: StrategyType.gem,
      cash: 10000.0,
      currency: const FiatCurrency.pln(),
      beginDate: epoch,
      endDate: epoch,
      analysisPeriod: PeriodType.year,
      name: '',
      mainAsset: GemAsset(
        type: GemAssetType.equity, asset: AssetConfig.defaultAsset(),
        supportingAssets: []),
      momentumAsset: GemAsset(
        type: GemAssetType.bond, asset: AssetConfig.defaultAsset(),
        supportingAssets: []),
    );
  }

  Strategy copyWith({int? newId, String? newName,
    StrategyType? newType,
    double? newCash,
    FiatCurrency? newCurrency,
    PeriodType? newAnalysisPeriod,
    DateTime? newBeginDate,
    DateTime? newEndDate,
    GemAsset? newMainAsset,
    GemAsset? newMomentumAsset}) {

    return GemStrategyConfig(
      id: newId ?? id,
      name: newName ?? name,
      type: newType ?? type,
      cash: newCash ?? cash,
      currency: newCurrency ?? currency,
      analysisPeriod: newAnalysisPeriod ?? analysisPeriod,
      beginDate: newBeginDate ?? beginDate,
      endDate: newEndDate ?? endDate,
      mainAsset: newMainAsset ?? mainAsset,
      momentumAsset: newMomentumAsset ?? momentumAsset);
  }

  @override
  factory GemStrategyConfig.fromMap(int id, String name,
      double cash,
      FiatCurrency currency,
      PeriodType analysisPeriod,
      DateTime beginDate, DateTime endDate,
      Map<String, dynamic> params) {

    final jsonMainAsset = params['main-asset'] as Map<String, dynamic>;
    final jsonMomentumAsset = params['momentum-assets'] as Map<String, dynamic>;

    return GemStrategyConfig(id: id, type: StrategyType.gem, name: name,
        cash: cash, currency: currency, analysisPeriod: analysisPeriod,
        beginDate: beginDate, endDate: endDate,
        mainAsset: GemAsset.fromMap(jsonMainAsset),
        momentumAsset: GemAsset.fromMap(jsonMomentumAsset));
  }

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    "main-asset": mainAsset.toMap(),
    "momentum-assets": momentumAsset.toMap()
  };

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is GemStrategyConfig &&
      runtimeType == other.runtimeType &&
      super == other &&
      mainAsset == other.mainAsset &&
      momentumAsset == other.momentumAsset);


  @override
  int get hashCode => Object.hash(
      super.hashCode,
      mainAsset,
      momentumAsset,);

  @override
  List<Object?> get props => [...super.props, mainAsset, momentumAsset];
}