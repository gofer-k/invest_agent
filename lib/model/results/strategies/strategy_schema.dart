import 'dart:convert';

import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/results/asset_allocation.dart';
import 'package:invest_agent/model/results/strategies/global_equity_momentum.dart';
import 'package:invest_agent/model/results/strategies/mean_reversion.dart';

import '../../asset_config.dart';

class StrategySchema implements CacheSchema {
  const StrategySchema();
  static const String tableName = "strategy";
  static const String sequenceName = "strategy_id_seq";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      type TEXT NOT NULL,
      name TEXT NOT NULL UNIQUE,
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
          type = excluded.type,
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

  static const int defaultId = -1;

  Strategy({required this.id, required this.type, required this.name})
      : super.from([]);

  Strategy fillAssets(List<AssetConfig> assets) => this;

  factory Strategy.emptyStrategy() {
    return Strategy(id: defaultId, type: StrategyType.asset, name: '');
  }

  Strategy copyWith({
    int? newId,
    String? newName,
    StrategyType? newType}) {
    return Strategy(
        id: newId ?? id,
        name: newName ?? name,
        type: newType ?? type);
  }

  factory Strategy.of({int id = defaultId}) {
    return Strategy(
        id: id,
        type: StrategyType.empty,
        name: '');
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

      return switch(jsonType) {
        StrategyType.arbitrary =>
        throw UnimplementedError(),
        StrategyType.asset =>
        throw UnimplementedError(),
        StrategyType.gem =>
            GemStrategyConfig.fromMap(strategyId, nameString, jsonParams),
        StrategyType.meanReversion =>
            MeanReversionConfig.fromMap(strategyId, nameString, jsonParams),
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
    return {
      "type": type.name,
      "name": name
    };
  }

  bool isEmpty() => id == defaultId && type == StrategyType.empty;

  @override
  List<Object?> get props => [id, type, name];

  @override
  bool operator ==(Object other) =>
      (identical(this, other)) ||
          (other is Strategy &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              type == other.type &&
              name == other.name);

  @override
  int get hashCode => Object.hash(id, name, type);

  @override
  String toString() => "${type.name} $name ($id)";

  List<AssetAllocation> getAssetAllocations() => [];
}
