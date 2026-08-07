import 'dart:convert';

import 'package:collection/collection.dart';
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
      '${config.parameters}'
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
          parameters = '${config.parameters}'
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
  gem("Global equity momentum"),
  asset("Asset allocation"),
  empty("-");

  final String name;
  const StrategyType(this.name);
}

class Strategy extends Cache {
  final int id;
  final StrategyType type;
  final String name;
  final Map<String, dynamic> parameters;

  Strategy({
    required this.id,
    required this.type,
    required this.parameters,
    required this.name}) : super.from([]);

  // factory Strategy.fromMap(Map<String, dynamic> item) {
  //
  // }
  bool isEmpty() => id == -1 && type == StrategyType.empty;

  Strategy copyWith({
    String? newName,
    StrategyType? newType,
    String? newDescription,
    Map<String, dynamic>? newParams}) {
    return Strategy(
        id: id,
        type: newType ?? type,
        parameters: newParams ?? parameters, name: newName ?? name);
  }

  static Strategy emptyStrategy() {
    return Strategy(
      id: -1,
      type: StrategyType.asset,
      parameters: {},
      name: '',
    );
  }

  CacheUniqueKey get uniqueKey {
    // Normalize parameters to ensure stability across gRPC/JSON round-trips
    final normalized = Cache.normalizeKey(parameters);
    return "$name-$type-${jsonEncode(normalized)}".hashCode;
  }

  @override
  List<Object?> get props => [id, type, parameters];

  @override
  bool operator ==(Object other) =>
    (identical(this, other)) ||
    (other is Strategy &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    type == other.type &&
    name == other.name &&
    const MapEquality().equals(parameters, other.parameters));

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ name.hashCode ^ const MapEquality().hash(parameters);

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

