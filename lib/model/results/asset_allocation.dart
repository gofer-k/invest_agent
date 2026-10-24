
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/indicator_schema.dart';

import '../asset_config.dart';

class AssetAllocation extends Equatable {
  final AssetConfig asset;
  final double targetWeight;  // Percentage of the portfolio
  final int assetSharesCount;
  final Set<Indicator> indicators;

  const AssetAllocation({
    required this.asset,
    required this.targetWeight,
    required this.assetSharesCount,
    this.indicators = const {}});

  factory AssetAllocation.of({
    required AssetConfig? asset, double? targetWeight, int? assetSharesCount}) {
    return AssetAllocation(
        asset: asset ?? AssetConfig.defaultAsset(),
        targetWeight: targetWeight ?? 100.0,
        assetSharesCount: assetSharesCount ?? 0);
  }

  factory AssetAllocation.fromMap(Map<String, dynamic> map) {
    int assetId = map['asset_id'] as int? ?? AssetConfig.defaultAssetId;
    final jsonIndicators = jsonDecode((map['indicators'] as List<dynamic>) as String);
    final indicatorList = jsonIndicators as List<dynamic>;
    final Set<Indicator> indicators = indicatorList.map((e) => Indicator.fromMap(e as Map<String, dynamic>)).toSet();

    return AssetAllocation(
      asset: AssetConfig.of(id: assetId),
      targetWeight: (map['target_weight'] as num).toDouble(),
      assetSharesCount: map['asset_shares_count'] as int,
      indicators: indicators,
    );
  }

  AssetAllocation copyWith({
    AssetConfig? newAsset,
    double? newTargetWeight,
    int? newAssetSharesCount,
    Set<Indicator>? newIndicators
  }) => AssetAllocation(
    asset: newAsset ?? asset,
    targetWeight: newTargetWeight ?? targetWeight,
    assetSharesCount: newAssetSharesCount ?? assetSharesCount,
    indicators: newIndicators ?? indicators
  );

  Map<String, dynamic> toMap() => {
    'asset_id': asset.id,
    'target_weight': targetWeight,
    'asset_shares_count': assetSharesCount,
    'indicators': jsonEncode(indicators.map((e) => e.toMap()).toList())
  };

  @override
  String toString() => 'AssetAllocation(assetId: ${asset.symbol}, targetWeight: $targetWeight, assetSharesCount: $assetSharesCount)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is AssetAllocation &&
      runtimeType == other.runtimeType &&
      asset == other.asset &&
      targetWeight == other.targetWeight &&
      assetSharesCount == other.assetSharesCount &&
      SetEquality().equals(indicators, other.indicators);

  @override
  int get hashCode => Object.hash(asset, targetWeight, assetSharesCount,
      const SetEquality().hash(indicators));

  @override
  List<Object?> get props => [asset, targetWeight, assetSharesCount, indicators];
}