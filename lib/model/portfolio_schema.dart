import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/period_type.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:money2/money2.dart';

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
      risk_free_rate FLOAT NOT NULL,
      initial_capital FLOAT,
      currency TEXT,
      strategy TEXT,  -- JSON string
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

    return '''
     INSERT INTO $tableName (id, portfolio_name, portfolio_desc, beginDate, endDate, analysisPeriod, allocations, strategy, risk_free_rate, initial_capital, currency)
      VALUES (
      nextval('$tableSequenceName'),
      '${portfolioConfig.portfolioName}',
      '${portfolioConfig.portfolioDesc}',
      '${portfolioConfig.startDateTime.toIso8601String()}',
      '${portfolioConfig.endDateTime.toIso8601String()}',
      '${portfolioConfig.analysisPeriod?.name}',
      ${portfolioConfig.riskFreeRatePerYear},
      ${portfolioConfig.initialCapital.amount.toDecimal().toDouble()},
      '${portfolioConfig.initialCapital.currency.isoCode}',
      '${jsonEncode(portfolioConfig.strategy?.toMap())}'
      );
     ''';
  }

  @override
  String updateOne(Cache cache) {
    final portfolioConfig = cache as PortfolioConfig;
    final id = portfolioConfig.id;

    return '''
      UPDATE $tableName
      SET portfolio_name = '${portfolioConfig.portfolioName}',
          portfolio_desc = '${portfolioConfig.portfolioDesc}',
          beginDate = '${portfolioConfig.startDateTime.toIso8601String()}',
          endDate = '${portfolioConfig.endDateTime.toIso8601String()}',
          analysisPeriod = '${portfolioConfig.analysisPeriod?.name}',          
          risk_free_rate = ${portfolioConfig.riskFreeRatePerYear},
          initial_capital = ${portfolioConfig.initialCapital.amount.toDecimal().toDouble()},
          currency = '${portfolioConfig.initialCapital.currency.isoCode}',
          strategy = '${jsonEncode(portfolioConfig.strategy?.toMap())}'
      WHERE id = $id;
      ''';
  }
}

class PortfolioConfig implements Cache {
  final int? id;
  final String portfolioName;
  final String portfolioDesc;
  final double riskFreeRatePerYear;
  final Money initialCapital;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final PeriodType? analysisPeriod;
  static const double defaultRiskFreeRate = 0.05;
  static final Money defaultCapital = Money.fromNum(10000, isoCode: 'PLN');
  final Strategy? strategy;

  PortfolioConfig({
    this.id,
    this.portfolioName = "",
    this.portfolioDesc = "",
    this.riskFreeRatePerYear = defaultRiskFreeRate,
    required this.startDateTime,
    required this.endDateTime,
    this.analysisPeriod = PeriodType.fiveYears,
    Money? initialCapital,
    this.strategy}
  ): initialCapital = initialCapital ?? defaultCapital;


  factory PortfolioConfig.emptyPortfolio() {
    final firstAllowedDate = DateTime(2000);
    return PortfolioConfig(
      portfolioName: "",
      portfolioDesc: "",
      riskFreeRatePerYear: defaultRiskFreeRate,
      startDateTime: firstAllowedDate,
      endDateTime: firstAllowedDate,
      analysisPeriod: PeriodType.fiveYears,
      initialCapital: defaultCapital,
      strategy: Strategy.emptyStrategy()
    );
  }

  PortfolioConfig copyWith({
    int? newId,
    String? newName,
    String? newDesc,
    Money? newInitialCapital,
    double? newRiskFreeRatePerYear,
    DateTime? newStartDateTime,
    DateTime? newEndDateTime,
    PeriodType? newAnalysisPeriod,
    Strategy? newStrategy}) {
    return PortfolioConfig(
      id: newId ?? id,
      portfolioName: newName ?? portfolioName,
      portfolioDesc: newDesc ?? portfolioDesc,
      initialCapital: newInitialCapital ?? initialCapital,
      riskFreeRatePerYear: newRiskFreeRatePerYear ?? riskFreeRatePerYear,
      startDateTime: newStartDateTime ?? startDateTime,
      endDateTime: newEndDateTime ?? endDateTime,
      analysisPeriod: newAnalysisPeriod ?? analysisPeriod,
      strategy: newStrategy ?? strategy,
    );
  }

  @override
  factory PortfolioConfig.fromMap(List<Object?> item) {
    if (item.isEmpty || item.length < 10) {
      throw Exception("Invalid input data");
    }

    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final beginDate = DateTime.tryParse(item[3] as String) ?? epoch;
    final endDate = DateTime.tryParse(item[4] as String) ?? epoch;

    // HEAL: If the DB contains "FiatCurrencyEnum.pln", extract just "PLN"
    String currencyCode = (item[9] as String? ?? 'PLN');
    if (currencyCode.contains('.')) {
      currencyCode = currencyCode.split('.').last.toUpperCase();
    } else {
      currencyCode = currencyCode.toUpperCase();
    }

    final capital = Money.fromNum(item[7] as double? ?? 10000.0, isoCode: currencyCode);

    final jsonStrategy = jsonDecode(item[10] as String) as Map<String, dynamic>;

    return PortfolioConfig(
      id: item[0] as int?,
      portfolioName: item[1] as String,
      portfolioDesc: item[2] as String? ?? "",
      startDateTime: beginDate,
      endDateTime: endDate,
      analysisPeriod: PeriodType.values.firstWhereOrNull((e) => e.name == item[5] as String),
      riskFreeRatePerYear: (item[6] as num? ?? defaultRiskFreeRate).toDouble(),
      initialCapital: capital,
      strategy: Strategy.from(jsonStrategy.entries.toList())
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'portfolio_name': portfolioName,
      'portfolio_desc': portfolioDesc,
      "beginDate": startDateTime.toIso8601String(),
      "endDate": endDateTime.toIso8601String(),
      "analysisPeriod": analysisPeriod?.name,
      'risk_free_rate': riskFreeRatePerYear,
      'initial_capital': initialCapital.amount.toDecimal().toDouble(),
      'currency': initialCapital.currency.isoCode,
      'strategy': strategy?.toMap()
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
      startDateTime,
      endDateTime,
      strategy,
      analysisPeriod,
      initialCapital);

  @override
  List<Object?> get props => [id, portfolioName, portfolioDesc,
    riskFreeRatePerYear, startDateTime, endDateTime,
    strategy, analysisPeriod, initialCapital];

  bool isEmpty() => id == null && portfolioName.isEmpty;

  @override
  bool? get stringify => true;

  PortfolioConfig fillAssets(List<AssetConfig> assets) {
    if (assets.isEmpty) return this;
    return strategy != null ? copyWith(newStrategy: strategy?.fillAssets(assets)) : this;
  }
}
