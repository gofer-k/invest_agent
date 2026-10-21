import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/period_type.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:money2/money2.dart';

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
      beginDate TIMESTAMP,
      endDate TIMESTAMP,
      analysisPeriod TEXT,
      allocations TEXT NOT NULL,
      strategy_id INTEGER REFERENCES strategy(id),
      risk_free_rate FLOAT NOT NULL,
      initial_capital FLOAT,
      currency TEXT
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
  String readOne(Cache cache) => ''' SELECT * FROM $tableName WHERE id = ${(cache as PortfolioConfig).id}; ''';

  @override
  String saveOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final allocations = jsonEncode(portfolioConfig.assetAllocations.map((e) => e.toMap()).toList());

    return '''
     INSERT INTO $tableName (id, portfolio_name, portfolio_desc, beginDate, endDate, analysisPeriod, allocations, strategy_id, risk_free_rate, initial_capital, currency)
      VALUES (
      nextval('$tableSequenceName'),
      '${portfolioConfig.portfolioName}',
      '${portfolioConfig.portfolioDesc}',
      '${portfolioConfig.startDateTime.toIso8601String()}',
      '${portfolioConfig.endDateTime.toIso8601String()}',
      '${portfolioConfig.analysisPeriod?.name}',
      '$allocations',
      ${portfolioConfig.strategy?.id},
      ${portfolioConfig.riskFreeRatePerYear},
      ${portfolioConfig.initialCapital.amount.toDecimal().toDouble()},
      '${portfolioConfig.initialCapital.currency.isoCode}'
      );
     ''';
  }

  @override
  String updateOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final id = portfolioConfig.id;
    final allocations = jsonEncode(portfolioConfig.assetAllocations.map((e) => e.toMap()).toList());

    return '''
      UPDATE $tableName
      SET portfolio_name = '${portfolioConfig.portfolioName}',
          portfolio_desc = '${portfolioConfig.portfolioDesc}',
          beginDate = '${portfolioConfig.startDateTime.toIso8601String()}',
          endDate = '${portfolioConfig.endDateTime.toIso8601String()}',
          analysisPeriod = '${portfolioConfig.analysisPeriod?.name}',
          allocations = '$allocations',
          strategy_id = ${portfolioConfig.strategy?.id},
          risk_free_rate = ${portfolioConfig.riskFreeRatePerYear},
          initial_capital = ${portfolioConfig.initialCapital.amount.toDecimal().toDouble()},
          currency = '${portfolioConfig.initialCapital.currency.isoCode}'
      WHERE id = $id;
      ''';
  }
}

class AssetAllocation extends Equatable {
  final AssetConfig asset;
  final double targetWeight;  // Percentage of the portfolio
  final int assetSharesCount;

  const AssetAllocation({
    required this.asset,
    required this.targetWeight,
    required this.assetSharesCount});

  factory AssetAllocation.of({required AssetConfig? asset, double? targetWeight, int? assetSharesCount}) {
    return AssetAllocation(
      asset: asset ?? AssetConfig.defaultAsset(),
      targetWeight: targetWeight ?? 100.0,
      assetSharesCount: assetSharesCount ?? 0);
  }

  factory AssetAllocation.fromMap(Map<String, dynamic> map) {
    int assetId = map['asset_id'] as int? ?? AssetConfig.defaultAssetId;
    return AssetAllocation(
      asset: AssetConfig.of(id: assetId),
      targetWeight: (map['target_weight'] as num).toDouble(),
      assetSharesCount: map['asset_shares_count'] as int,
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

class PortfolioConfig implements Cache {
  final int? id;
  final String portfolioName;
  final String portfolioDesc;
  final double riskFreeRatePerYear;
  final Money initialCapital;
  final Set<AssetAllocation> assetAllocations;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final Strategy? strategy;
  final PeriodType? analysisPeriod;
  static const double defaultRiskFreeRate = 0.05;
  static final Money defaultCapital = Money.fromNum(10000, isoCode: 'PLN');

  PortfolioConfig({
    this.id,
    this.portfolioName = "",
    this.portfolioDesc = "",
    this.riskFreeRatePerYear = defaultRiskFreeRate,
    this.assetAllocations = const {},
    required this.startDateTime,
    required this.endDateTime,
    this.strategy,
    this.analysisPeriod = PeriodType.fiveYears,
    Money? initialCapital}
  ): initialCapital = initialCapital ?? defaultCapital;


  factory PortfolioConfig.emptyPortfolio() {
    final firstAllowedDate = DateTime(2000);
    return PortfolioConfig(
      portfolioName: "",
      portfolioDesc: "",
      riskFreeRatePerYear: defaultRiskFreeRate,
      startDateTime: firstAllowedDate,
      endDateTime: firstAllowedDate,
      assetAllocations: {},
      strategy: Strategy.emptyStrategy(),
      analysisPeriod: PeriodType.fiveYears,
      initialCapital: defaultCapital,
    );
  }

  PortfolioConfig copyWith({
    int? newId,
    String? newName,
    String? newDesc,
    Money? newInitialCapital,
    double? newRiskFreeRatePerYear,
    Set<AssetAllocation>? newAssetAllocations,
    DateTime? newStartDateTime,
    DateTime? newEndDateTime,
    PeriodType? newAnalysisPeriod,
    Strategy? newStrategy}) {
    return PortfolioConfig(
      id: newId ?? id,
      portfolioName: newName ?? portfolioName,
      portfolioDesc: newDesc ?? portfolioDesc,
      assetAllocations: newAssetAllocations ?? assetAllocations,
      initialCapital: newInitialCapital ?? initialCapital,
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
          assets.any((asset) => asset.id == allocation.asset.id)).toSet();

    return copyWith(newAssetAllocations: portfolioAllocations);
  }

  @override
  factory PortfolioConfig.fromMap(List<Object?> item) {
    if (item.isEmpty || item.length < 11) {
      throw Exception("Invalid input data");
    }

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final beginDate = DateTime.tryParse(item[3] as String) ?? epoch;
    final endDate = DateTime.tryParse(item[4] as String) ?? epoch;
    final jsonAllocations = jsonDecode(item[6] as String) as List<dynamic>;
    final allocations = jsonAllocations.map((e) => AssetAllocation.fromMap(e as Map<String, dynamic>)).toSet();
    
    // HEAL: If the DB contains "FiatCurrencyEnum.pln", extract just "PLN"
    String currencyCode = (item[10] as String? ?? 'PLN');
    if (currencyCode.contains('.')) {
      currencyCode = currencyCode.split('.').last.toUpperCase();
    } else {
      currencyCode = currencyCode.toUpperCase();
    }

    final capital = Money.fromNum(item[9] as double? ?? 10000.0, isoCode: currencyCode);

    return PortfolioConfig(
      id: item[0] as int?,
      portfolioName: item[1] as String,
      portfolioDesc: item[2] as String? ?? "",
      startDateTime: beginDate,
      endDateTime: endDate,
      analysisPeriod: PeriodType.values.firstWhereOrNull((e) => e.name == item[5] as String),
      assetAllocations: allocations,
      strategy: Strategy.of(id: item[7] as int? ?? Strategy.defaultId),
      riskFreeRatePerYear: (item[8] as num? ?? defaultRiskFreeRate).toDouble(),
      initialCapital: capital,
    );
  }

  AssetAllocation? getAssetAllocation(AssetConfig asset) {
    return assetAllocations.firstWhereOrNull((allocation) => allocation.asset == asset);
  }

  @override
  Map<String, dynamic> toMap() {
    final allocations = jsonEncode(assetAllocations.map((e) => e.toMap()).toList());
    return {
      'id': id,
      'portfolio_name': portfolioName,
      'portfolio_desc': portfolioDesc,
      "beginDate": startDateTime.toIso8601String(),
      "endDate": endDateTime.toIso8601String(),
      "analysisPeriod": analysisPeriod?.name,
      'allocations': allocations,
      'strategy_id': strategy?.id,
      'risk_free_rate': riskFreeRatePerYear,
      'initial_capital': initialCapital.amount.toDecimal().toDouble(),
      'currency': initialCapital.currency.isoCode,
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
          const SetEquality().equals(assetAllocations, other.assetAllocations) &&
          startDateTime == other.startDateTime &&
          endDateTime == other.endDateTime &&
          strategy == other.strategy &&
          analysisPeriod == other.analysisPeriod &&
          initialCapital == other.initialCapital;

  @override
  int get hashCode => Object.hash(
      id.hashCode,
      portfolioName,
      portfolioDesc,
      riskFreeRatePerYear,
      const SetEquality().hash(assetAllocations),
      startDateTime,
      endDateTime,
      strategy,
      analysisPeriod,
      initialCapital);

  @override
  List<Object?> get props => [id, portfolioName, portfolioDesc,
    riskFreeRatePerYear, assetAllocations, startDateTime, endDateTime,
    strategy, analysisPeriod, initialCapital];

  bool isEmpty() => id == null && portfolioName.isEmpty;

  @override
  bool? get stringify => true;
}
