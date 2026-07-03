import 'package:flutter/material.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

enum IndicatorType {
  price("Price", "Price"),
  bellingerBands("Bollinger Bands", "Bollinger Bands"),
  sma("Simple Moving Average", "SMA"),
  ema("Exponential Moving Average", "EMA"),
  macd("Moving Average Convergence/Divergence", "MACD"),
  rsi("Relative Strength Index", "RSI"),
  volume("Volume", "Volume"),
  undefined("Undefined", ""),
  kst("Know Sure Thing", "KST"),
  roc("Rate of Change", "ROC"),;

  // Renamed 'name' to 'label' to avoid shadowing built-in Enum.name
  const IndicatorType(this.label, this.shortName);
  final String label;
  final String shortName;

  @override
  String toString() => shortName;
}

class IndicatorSchema implements CacheSchema {
  const IndicatorSchema();

  static const String tableName = "indicators";
  static const String sequenceName = "indicators_id_seq";

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $sequenceName START 1;";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      name TEXT NOT NULL UNIQUE,
      type TEXT NOT NULL,
      parameters TEXT, -- JSON string
    );
  ''';

  @override
  String get readAll => "SELECT * FROM $tableName ORDER BY name;";

  @override
  String readOne(Cache cache) => "SELECT * FROM $tableName WHERE id = ${(cache as Indicator).id};";

  @override
  String saveOne(Cache cache) {
    final config = cache as Indicator;
    return '''
      INSERT INTO $tableName 
      VALUES (
      nextval('$sequenceName'),
      '${config.name}',
      '${config.type.name}', 
      '${jsonEncode(config.parameters)}'
       ) ON CONFLICT(name) DO UPDATE SET
          type = excluded.type,
          parameters = excluded.parameters;
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final config = cache as Indicator;
    return '''
      UPDATE $tableName
      SET name = '${config.name}',
          type = '${config.type.name}',
          parameters = '${jsonEncode(config.parameters)}'
      WHERE id = ${config.id};
    ''';
  }

  @override
  String deleteOne(Cache cache) => "DELETE FROM $tableName WHERE id = ${(cache as Indicator).id};";

  @override
  String get deleteAll => "DELETE FROM $tableName;";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicatorSchema && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

typedef IndicatorKey = int;

class Indicator extends Cache {
  final int id;
  final String name; // friendly an indicator's name
  final IndicatorType type;  // an indicator's type
  final Map<String, dynamic> parameters;

  static const String mainChart = "main_chart";
  
  Indicator({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
  }) : super.from([]);

  IndicatorKey get uniqueKey {
    // Normalize parameters to ensure stability across gRPC/JSON round-trips
    final normalized = _normalize(parameters);
    return "$name-$type-${jsonEncode(normalized)}".hashCode;
  }

  /// Recursively normalizes maps and lists for stable hashing/stringifying.
  /// 1. Sorts map keys.
  /// 2. Collapses single-element lists (common gRPC/Protobuf Struct artifact).
  /// 3. Converts all numbers to doubles to avoid int/double mismatch.
  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((e) => e.toString()).toList()..sort();
      return {
        for (final k in sortedKeys) k: _normalize(value[k])
      };
    } else if (value is List) {
      if (value.length == 1) return _normalize(value[0]);
      return value.map(_normalize).toList();
    } else if (value is num) {
      return value.toDouble();
    }
    return value;
  }

  @override
  factory Indicator.from(List<Object?> item) {
    if (item.length >= 4) {
      final jsonParameters = jsonDecode(item[3] as String);
      final typeString = item[2] as String;
      
      // Resilience: check enum name (sma), label (Simple Moving Average), and shortName (SMA)
      final jsonType = IndicatorType.values.firstWhere(
        (e) => e.name == typeString || 
               e.label == typeString || 
               e.shortName == typeString ||
               e.name.toLowerCase() == typeString.toLowerCase(),
        orElse: () => IndicatorType.undefined
      );
      
      return Indicator(
        id: item[0] as int,
        name: item[1] as String,
        type: jsonType,
        parameters: jsonParameters,
      );
    }
    return defaultIndicator();
  }

  factory Indicator.fromMap(Map<String, dynamic> item) {
    final typeData = item['type'];
    IndicatorType type;
    if (typeData is String) {
      // Resilience: check enum name (sma), label (Simple Moving Average), and shortName (SMA)
      type = IndicatorType.values.firstWhere(
        (e) => e.name == typeData || 
               e.label == typeData || 
               e.shortName == typeData ||
               e.name.toLowerCase() == typeData.toLowerCase(),
        orElse: () => IndicatorType.undefined
      );
    } else {
      type = typeData as IndicatorType? ?? IndicatorType.undefined;
    }

    return Indicator(
      id: item['id'] as int? ?? -1,
      type: type,
      name: item['name'] as String? ?? '',
      parameters: item['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Map<String, dynamic> toMap() =>   {
    'id': id,
    'name': name,
    'type': type.name, // Persist using standard enum name (e.g. "sma")
    'parameters': parameters,
  };

  @override
  String toString() => name;

  String toDetailedString() {
    return "$name ${parameters.values.toString()}";
  }

  static Indicator defaultIndicator() {
    return Indicator(
      id: -1,
      name: '-',
      type: IndicatorType.undefined,
      parameters: {mainChart: false},
    );
  }

  static Indicator priceIndicator() {
    return Indicator(
      id: -2,
      name: 'Asset price',
      type: IndicatorType.price,
      parameters: {
        mainChart: true
      },
    );
  }

  Indicator copyWith({String? newName, IndicatorType? newType, bool? isMainChart}) {
    final newParams = Map<String, dynamic>.from(parameters);
    newParams[mainChart] = isMainChart ?? newParams[mainChart];
    return Indicator(
        id: id,
        name: newName ?? name,
        type: newType ?? type,
        parameters: newParams);
  }

  Color color() {
    return parameters["color"] != null ? Color(parameters["color"]) : Colors.blueAccent;
  }

  bool isDefault() {
    return id == -1 && type == IndicatorType.undefined;
  }

  bool isMainChart() {
    return parameters[mainChart] ?? false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Indicator &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          const MapEquality().equals(parameters, other.parameters);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      const MapEquality().hash(parameters);
}
