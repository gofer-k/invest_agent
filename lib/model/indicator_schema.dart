import 'package:invest_agent/model/cache_schema.dart';
import 'dart:convert';

enum IndicatorType {
  price("Price"),
  bellingerBands("Bollinger Bands"),
  sma("Simple Moving Average"),
  ema("Exponential Moving Average"),
  macd("Moving Average Convergence/Divergence"),
  rsi("Relative Strength Index"),
  volume("Volume"),
  undefined("Undefined"),
  kst("Know Sure Thing"),
  roc("Rate of Change"),;

  const IndicatorType(this.name);
  final String name;
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
      type: item['type'] as IndicatorType,
      name: item['name'] as String? ?? '',
      parameters: item['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Map<String, dynamic> toMap() =>   {
    'id': id,
    'name': name,
    'type': type,
    'parameters': parameters,
  };

  @override
  String toString() => name;

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
    parameters[mainChart] = isMainChart ?? parameters[mainChart];
    return Indicator(
        id: id,
        name: newName ?? name,
        type: newType ?? type,
        parameters: parameters);
  }
  
  bool isDefault() {
    return id == -1 && type == IndicatorType.undefined;
  }

  bool isMainChart() {
    return parameters["_mainChart"] ?? false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Indicator && runtimeType == other.runtimeType &&
      id == other.id && // TODO: Consider not use it here
      name == other.name &&
      type == other.type &&
      parameters == other.parameters;

  @override
  int get hashCode =>
      id.hashCode ^ // TODO:Consider not use it here
      name.hashCode ^
      type.hashCode ^
      parameters.hashCode;
}
