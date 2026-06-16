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

  const IndicatorType(this.name, this.shortName);
  final String name;
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

  @override
  factory Indicator.from(List<Object?> item) {
    if (item.length >= 4) {
      final jsonParameters = jsonDecode(item[3] as String);
      final jsonType = IndicatorType.values.firstWhere((e) => e.name == item[2] as String);
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
    return Indicator(
      id: item['id'] as int? ?? -1,
      type: item['type'] is String 
          ? IndicatorType.values.firstWhere((e) => e.name == item['type'])
          : item['type'] as IndicatorType,
      name: item['name'] as String? ?? '',
      parameters: item['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Map<String, dynamic> toMap() =>   {
    'id': id,
    'name': name,
    'type': type.name,
    'parameters': parameters,
  };

  @override
  String toString() => name;

  String toInfoString() {
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
      name: 'Asset;s price',
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
