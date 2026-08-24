import 'dart:convert';

import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/results/strategies/global_equity_momentum.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

import '../../../widgets/dialogs/asset_dialog.dart';
import '../../period_type.dart';
import 'mean_reversion.dart';

class StrategySchema implements CacheSchema {
  const StrategySchema();
  static const String tableName = "strategy";
  static const String sequenceName = "strategy_id_seq";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      type TEXT NOT NULL,
      name TEXT UNIQUE,
      parameters TEXT -- JSON string
    );
  ''';

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $sequenceName START 1;";

  @override
  String get deleteAll => "DELETE FROM $tableName;";

  @override
  String deleteOne(Cache cache) =>
      "DELETE FROM $tableName WHERE id = ${(cache as Strategy).id};";

  @override
  String get readAll => "SELECT * FROM $tableName ORDER BY name;";

  @override
  String readOne(Cache cache) =>
      "SELECT * FROM $tableName WHERE id = ${(cache as Strategy).id};";

  @override
  String saveOne(Cache cache) {
    final config = cache as Strategy;
    return '''
      INSERT INTO $tableName 
      VALUES (
      nextval('$sequenceName'),
      '${config.type.name}',
      '${config.name}', 
      '${jsonEncode(config.toMap())}'
      ) ON CONFLICT(name) DO UPDATE SET
          parameters = excluded.parameters;
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final config = cache as Strategy;
    return '''
      UPDATE $tableName
      SET type = '${config.type.name}',
          name = '${config.name}',
          parameters = '${jsonEncode(config.toMap())}'
      WHERE id = ${config.id};
    ''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategySchema && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

enum StrategyType {
  arbitrary("Arbitrary"),
  asset("Asset allocation"),
  gem("Global equity momentum"),
  meanReversion("Mean reversion"),
  indexFundRebalancing("Index fund rebalancing"),
  trendFollowing("Trend following"),
  empty("-");

  final String name;
  const StrategyType(this.name);
}

class Strategy extends Cache {
  final int id;
  final StrategyType type;
  final String name;
  final double cash;
  final FiatCurrencyEnum currency;
  final PeriodType analysisPeriod;
  final DateTime beginDate;
  final DateTime endDate;

  static const int defaultId = -1;
  static const double defaultBudget = 10000.0;
  static const FiatCurrencyEnum defaultCurrency = FiatCurrencyEnum.pln;
  static const PeriodType defaultPeriod = PeriodType.year;

  Strategy({
    required this.id,
    required this.type,
    required this.name,
    this.cash = Strategy.defaultBudget,
    this.currency = defaultCurrency,
    this.analysisPeriod = defaultPeriod,
    required this.beginDate,
    required this.endDate}) : super.from([]);

  factory Strategy.emptyStrategy() {
    final firstAllowedDate = DateTime(2000);
    return Strategy(
      id: defaultId,
      type: StrategyType.asset,
      name: '',
      beginDate: firstAllowedDate,
      endDate: firstAllowedDate,
    );
  }

  Strategy copyWith({
    int? newId,
    String? newName,
    StrategyType? newType,
    double? newCash,
    FiatCurrencyEnum? newCurrency,
    PeriodType? newAnalysisPeriod,
    DateTime? newBeginDate,
    DateTime? newEndDate}) {
    final firstAllowedDate = DateTime(2000);

    return Strategy(
      id: newId ?? id,
      name: newName ?? name,
      type: newType ?? type,
      cash: newCash ?? cash,
      currency: newCurrency ?? currency,
      analysisPeriod: newAnalysisPeriod ?? analysisPeriod,
      beginDate: newBeginDate ?? firstAllowedDate,
      endDate: newEndDate ?? firstAllowedDate);
  }

  @override
  factory Strategy.from(List<Object?> item) {
    if (item.length >= 3) {
      final strategyId = item[0] as int;
      final typeString = (item[1] as String).toLowerCase();
      // Resilience: check enum type
      final jsonType = StrategyType.values.firstWhere(
              (e) => e.name.toLowerCase() == typeString,
          orElse: () => StrategyType.empty
      );
      final nameString = item[2] as String;
      final jsonParamsString = item[3] as String;
      final jsonParams = jsonDecode(jsonParamsString) as Map<String, dynamic>;

      // General strategy params
      final cash = jsonParams['cash'] as double? ?? 10000.0;
      final jsonCurrency = jsonParams['currency'] as String? ?? 'pln';
      final currency = FiatCurrencyEnum.fromCurrency(FiatCurrency.maybeFromCode(jsonCurrency.toUpperCase()));
      if (currency == null) {
        throw Exception("Invalidate input currency: $jsonCurrency. It must tbe compatible to ISO 4217 code");
      }
      final analysisPeriod = PeriodType.values.firstWhere((e) => e.name == jsonParams['analysisPeriod'] as String);
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final beginDate = DateTime.tryParse(jsonParams['beginDate'] as String) ?? epoch;
      final endDate = DateTime.tryParse(jsonParams['endDate'] as String) ?? epoch;

      return switch(jsonType) {
        StrategyType.arbitrary =>
        throw UnimplementedError(),
        StrategyType.asset =>
        throw UnimplementedError(),
        StrategyType.gem =>
          GemStrategyConfig.fromMap(strategyId, nameString, cash, currency, analysisPeriod, beginDate, endDate, jsonParams),
        StrategyType.meanReversion =>
          MeanReversionConfig.fromMap(strategyId, nameString, cash, currency, analysisPeriod, beginDate, endDate, jsonParams),
        StrategyType.indexFundRebalancing =>
        throw UnimplementedError(),
        StrategyType.trendFollowing =>
        throw UnimplementedError(),
        StrategyType.empty => Strategy.emptyStrategy()
      };
    }
    return Strategy.emptyStrategy();
  }

  @override
  Map<String, dynamic> toMap() {
    // final parameters = switch(this) {
    //   final MeanReversionConfig strategy => strategy.toMap(),
    //   final GemStrategyConfig strategy => strategy.toMap(),
    // // TODO: add other strategies
    //   _ => <String, dynamic>{},
    // };
    //
    // parameters['cash'] = cash;
    // parameters['currency'] = currency.code;
    // parameters['analysisPeriod'] = analysisPeriod.name;
    // parameters['beginDate'] = beginDate.toIso8601String();
    // parameters['endDate'] = endDate.toIso8601String();
    //
    // return {
    //   "id": id,
    //   "type": type.name,
    //   "name": name,
    //   "parameters": parameters,
    // };
    return {
      "cash": cash,
      "currency": currency.data.code,
      "analysisPeriod": analysisPeriod.name,
      "beginDate": beginDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
    };
  }

  bool isEmpty() => id == defaultId && type == StrategyType.empty;

  @override
  List<Object?> get props => [id, type, name, cash, currency, analysisPeriod, beginDate, endDate];

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is Strategy &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    type == other.type &&
    name == other.name &&
    cash == other.cash &&
    currency == other.currency &&
    analysisPeriod == other.analysisPeriod &&
    beginDate.isAtSameMomentAs(other.beginDate) &&
    endDate.isAtSameMomentAs(other.endDate));

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    cash,
    currency,
    analysisPeriod,
    beginDate,
    endDate);

  @override
  String toString() => type.name;
}

