import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/period_type.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';

import 'asset_config.dart';

class PortfolioConfigSchema implements CacheSchema {
  const PortfolioConfigSchema();
  static const String tableName = "portfolio";
  static const String tableSequenceName = "portfolio_sequence";

  @override
  String get create =>
    '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$tableSequenceName'),
      portfolio_name TEXT NOT NULL,
      portfolio_desc TEXT DEFAULT '',
      created_at TIMESTAMP,
      assets TEXT, -- string array format: [1, 2, 45, ...]
      risk_free_rate FLOAT NOT NULL
    );
    ''';

  @override
  String get createKey => ''' CREATE SEQUENCE IF NOT EXISTS '$tableSequenceName' START 1; ''';

  @override
  String get deleteAll => ''' DELETE FROM $tableName; ''';

  @override
  String deleteOne(Cache cache) {
    final id = (cache as PortfolioConfig).id;
    return ''' DELETE FROM $tableName WHERE id = $id; ''';
  }

  @override
  String get readAll => ''' SELECT * FROM $tableName  ORDER BY portfolio_name; ''';

  @override
  String readOne(Cache cache) => ''' "SELECT * FROM $tableName WHERE id = ${(cache as PortfolioConfig).id}; ''';

  @override
  String saveOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final allocations = jsonEncode(portfolioConfig.assetAllocations.map((e) => e.toMap()).toList());

    return '''
     INSERT INTO $tableName
      VALUES ('
      nextval('$tableSequenceName'),
      '${portfolioConfig.portfolioName}',
      '${portfolioConfig.portfolioDesc}',
      '${portfolioConfig.createdDateTime.toIso8601String()}',
      $allocations,
      ${portfolioConfig.riskFreeRatePerYear},
      );
     ''';
  }

  @override
  String updateOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final id = portfolioConfig.id;
    final portfolioName = portfolioConfig.portfolioName;
    final portfolioDesc = portfolioConfig.portfolioDesc;
    final createdDateTime = portfolioConfig.createdDateTime;
    final allocations = jsonEncode(portfolioConfig.assetAllocations.map((e) => e.toMap()).toList());

    return '''
      UPDATE $tableName
      SET portfolio_name = '$portfolioName',
          portfolio_desc = '$portfolioDesc',
          created_at = '$createdDateTime',
          assets = $allocations,
          risk_free_rate = ${portfolioConfig.riskFreeRatePerYear}          
      WHERE id = $id;
      ''';
  }
}

class AssetAllocation extends Equatable {
  final AssetConfig asset;
  final double targetWeight;
  final int assetSharesCount;

  const AssetAllocation({
    required this.asset,
    required this.targetWeight,
    required this.assetSharesCount});

  factory AssetAllocation.fromMap(Map<String, dynamic> map) {
    int assetId = map['asset_id'] as int? ?? AssetConfig.defaultAssetId;
    return AssetAllocation(
      asset: AssetConfig.of(id: assetId),
      targetWeight: map['target_weight'],
      assetSharesCount: map['asset_shares_count'],
    );
  }

  AssetAllocation copyWith({
    AssetConfig? newAsset,
    double? newTargetWeight,
    int? newAssetSharesCount,
  }) => AssetAllocation(
    asset: newAsset ?? asset,
    targetWeight: newTargetWeight ?? targetWeight,
    assetSharesCount: newAssetSharesCount ?? assetSharesCount,
  );

  Map<String, dynamic> toMap() => {
    'asset_id': asset.id,
    'target_weight': targetWeight,
    'asset_shares_count': assetSharesCount,
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
      assetSharesCount == other.assetSharesCount;

  @override
  int get hashCode => Object.hash(asset, targetWeight, assetSharesCount);

  @override
  List<Object?> get props => [asset, targetWeight, assetSharesCount];
}

class PortfolioConfig implements Cache{
  final int? id;
  final String portfolioName;
  final String portfolioDesc;
  final double riskFreeRatePerYear;
  final List<AssetAllocation> assetAllocations;
  final DateTime createdDateTime;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final Strategy? strategy;
  final PeriodType? analysisPeriod;

  static const double defaultRiskFreeRate = 0.05;

  PortfolioConfig({
    this.id,
    this.portfolioName = "",
    this.portfolioDesc = "",
    this.riskFreeRatePerYear = defaultRiskFreeRate,
    required this.createdDateTime,
    this.assetAllocations = const [],
    this.startDateTime,
    this.endDateTime,
    this.strategy,
    this.analysisPeriod = PeriodType.fiveYears,});

  factory PortfolioConfig.emptyPortfolio() {
    return PortfolioConfig(
      portfolioName: "",
      portfolioDesc: "",
      riskFreeRatePerYear: defaultRiskFreeRate,
      createdDateTime: DateTime.now(),
      assetAllocations: [],
    );
  }

  PortfolioConfig copyWith({
    int? newId,
    String? newName,
    String? newDesc,
    double? newRiskFreeRatePerYear,
    List<AssetAllocation>? newAssetAllocations,
    DateTime? newCreatedDataTime,
    DateTime? newStartDateTime,
    DateTime? newEndDateTime,
    PeriodType? newAnalysisPeriod,
    Strategy? newStrategy}) {
    return PortfolioConfig(
      id: newId ?? id,
      portfolioName: newName ?? portfolioName,
      portfolioDesc: newDesc ?? portfolioDesc,
      assetAllocations: newAssetAllocations ?? assetAllocations,
      createdDateTime: newCreatedDataTime ?? createdDateTime,
      riskFreeRatePerYear: newRiskFreeRatePerYear ?? riskFreeRatePerYear,
      startDateTime: newStartDateTime ?? startDateTime,
      endDateTime: newEndDateTime ?? endDateTime,
      analysisPeriod: newAnalysisPeriod ?? analysisPeriod,
      strategy: newStrategy ?? strategy,
    );
  }

  PortfolioConfig fillAssets(List<AssetConfig> assets) {
    if (assets.isEmpty) return this;

    final portfolioAllocations = assetAllocations.where(
      (allocation) =>
          allocation.asset.id != AssetConfig.defaultAssetId &&
          assets.any((asset) => asset.id == allocation.asset.id)).toList();

    return copyWith(newAssetAllocations: portfolioAllocations);
  }

  @override
  factory PortfolioConfig.fromMap(List<Object?> item) {
    if (item.isEmpty && item.length < 9) {
      throw Exception("Invalidate input data");
    }
    final allocations = (item[4] as List).map(
      (allocation) => AssetAllocation.fromMap(allocation as Map<String, dynamic>)).toList();

    return PortfolioConfig(
      id: item[0] as int?,
      portfolioName: item[1] as String,
      portfolioDesc: item[2] as String,
      riskFreeRatePerYear: item[3] as double? ?? defaultRiskFreeRate,
      assetAllocations: allocations,
      createdDateTime: item[5] as DateTime,
      startDateTime: item[6] as DateTime?,
      endDateTime: item[7] as DateTime?,
      strategy: Strategy.of(id: item[8] as int? ?? Strategy.defaultId),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final allocations = jsonEncode(assetAllocations.map((e) => e.toMap()).toList());
    return {
      'id': id,
      'portfolio_name': portfolioName,
      'portfolio_desc': portfolioDesc,
      'risk_Free_rate': riskFreeRatePerYear,
      'assets': allocations,
      'created_at': createdDateTime,
    };
  }

  @override
  String toString() => portfolioName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          portfolioName == other.portfolioName &&
          portfolioDesc == other.portfolioDesc &&
          riskFreeRatePerYear == other.riskFreeRatePerYear &&
          const ListEquality().equals(assetAllocations, other.assetAllocations) &&
          createdDateTime == other.createdDateTime;

  @override
  int get hashCode => Object.hash(
      id.hashCode,
      portfolioName,
      portfolioDesc,
      riskFreeRatePerYear,
      const ListEquality().hash(assetAllocations),
      createdDateTime);

  @override
  List<Object?> get props => [id, portfolioName, portfolioDesc, riskFreeRatePerYear, assetAllocations, createdDateTime];

  @override
  bool? get stringify => true;

  bool isEmpty() => id == null && portfolioName.isEmpty;
}
