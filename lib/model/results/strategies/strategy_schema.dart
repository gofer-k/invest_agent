import 'dart:convert';

import 'package:invest_agent/model/cache_schema.dart';

class StrategySchema implements CacheSchema {
  const StrategySchema();
  static const String tableName = "strategy";
  static const String sequenceName = "strategy_id_seq";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      type TEXT NOT NULL,
      name TEXT,
      parameters TEXT, -- JSON string
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
  final Map<String, dynamic> parameters;

  static int defaultId = -1;

  Strategy({
    required this.id,
    required this.type,
    this.parameters = const {},
    required this.name}) : super.from([]);

  factory Strategy.emptyStrategy() {
    return Strategy(
      id: -1,
      type: StrategyType.asset,
      parameters: {},
      name: '',
    );
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
      final jsonParams = item[3] as Map<String, dynamic>;
      return Strategy(
        id: strategyId,
        type: jsonType,
        name: nameString,
        parameters: jsonParams,
      );
    }
    return Strategy.emptyStrategy();
  }

  bool isEmpty() => id == defaultId && type == StrategyType.empty;

  Strategy copyWith({
    int? newId,
    String? newName,
    StrategyType? newType,
    Map<String, dynamic>? newParameters}) {
    return Strategy(
        id: newId ?? id,
        type: newType ?? type,
        name: newName ?? name,
        parameters: parameters
    );
  }

  // CacheUniqueKey get uniqueKey {
  //   // Normalize parameters to ensure stability across gRPC/JSON round-trips
  //   final normalized = Cache.normalizeKey(parameters);
  //   return "$name-$type-${jsonEncode(normalized)}".hashCode;
  // }

  @override
  List<Object?> get props => [id, type, name, parameters];

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is Strategy &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    type == other.type &&
    name == other.name &&
    parameters == other.parameters);

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ name.hashCode ^ parameters.hashCode;

  @override
  Map<String, dynamic> toMap() => {
    "id": id,
    "type": type.name,
    "name": name,
    "parameters": parameters,
  };

  @override
  String toString() => type.name;
}

