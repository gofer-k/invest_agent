import 'package:flutter/material.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

enum IndicatorType {
  price("Price", "Price"),
  bollingerBands("Bollinger Bands", "Bollinger Bands"),
  sma("Simple Moving Average", "SMA"),
  ema("Exponential Moving Average", "EMA"),
  macd("Moving Average Convergence/Divergence", "MACD"),
  rsi("Relative Strength Index", "RSI"),
  volume("Volume", "Volume"),
  undefined("Undefined", ""),
  kst("Know Sure Thing", "KST"),
  roc("Rate of Change", "ROC"),;

  const IndicatorType(this.label, this.shortName);
  final String label;
  final String shortName;

  @override
  String toString() => shortName;
}

enum IndicatorParam { edit, visible, type, value }
enum IndicatorParamType { int, double, string, color }

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
  static int defaultId = -1;
  static int priceId = -2;

  Indicator({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
  }) : super.from([]);

  CacheUniqueKey get uniqueKey {
    // Normalize parameters to ensure stability across gRPC/JSON round-trips
    final normalized = Cache.normalizeKey(parameters);
    return "$name-$type-${jsonEncode(normalized)}".hashCode;
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
    return emptyIndicator();
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
      id: item['id'] as int? ?? defaultId,
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
    String result = name;

    String formatMap(String key, Map<String, dynamic> map) {
      final type = map[IndicatorParam.type.name];
      if (type == IndicatorParamType.color.name) return "";

      final value = map[IndicatorParam.value.name];
      if (value == null) return "";

      return " $key $value";
    }

    parameters.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result += formatMap(key, value);
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            item.forEach((subKey, subValue) {
              if (subValue is Map<String, dynamic>) {
                result += formatMap(subKey, subValue);
              }
            });
          } else if (item != null) {
            result += " $key: $item";
          }
        }
      }
    });
    return result;
  }

  static Indicator emptyIndicator() {
    return Indicator(
      id: defaultId,
      name: '-',
      type: IndicatorType.undefined,
      parameters: {mainChart: false},
    );
  }

  static Indicator priceIndicator() {
    return Indicator(
      id: priceId,
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

  Map<String, Color> colors() {
    final Map<String, Color> result = {};
    parameters.forEach((param, value) {
      if (value is Map<String, dynamic>) {
        if (value[IndicatorParam.type.name] == IndicatorParamType.color.name) {
          final colorValue = value[IndicatorParam.value.name];
          if (colorValue != null) {
            final hexString = colorValue.toString().replaceFirst('#', '');
            try {
              result[param] = Color(int.parse(hexString, radix: 16));
            } catch (_) {}
          }
        }
      }
    });
    return result;
  }

  Map<String, Color> visibleIndicatorColors() {
    final Map<String, Color> result = {};
    parameters.forEach((param, value) {
      if (value is Map<String, dynamic>) {
        if (value[IndicatorParam.type.name] == IndicatorParamType.color.name) {
          if (Cache.isVisible(value)) {
            final colorValue = value[IndicatorParam.value.name];
            if (colorValue != null) {
              final hexString = colorValue.toString().replaceFirst('#', '');
              try {
                result[param] = Color(int.parse(hexString, radix: 16));
              } catch (_) {}
            }
          }
        }
      }
    });
    return result;
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

  @override
  List<Object?> get props => [id, name, type, parameters];
}
