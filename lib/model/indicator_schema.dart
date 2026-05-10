import 'package:invest_agent/model/cache_schema.dart';
import 'dart:convert';

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
      is_enabled BOOLEAN DEFAULT TRUE
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
      '${config.type}', 
      '${jsonEncode(config.parameters)}',
       ${config.isEnabled}) ON CONFLICT(name) DO UPDATE SET
          type = excluded.type,
          parameters = excluded.parameters,
          is_enabled = excluded.is_enabled;
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final config = cache as Indicator;
    return '''
      UPDATE $tableName
      SET name = '${config.name}',
          type = '${config.type}',
          parameters = '${jsonEncode(config.parameters)}',
          is_enabled = ${config.isEnabled},
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
  final String name; // SMA, EMA, RSI, etc.
  final String type;  // friendly name of the indicator
  final Map<String, dynamic> parameters;
  final bool isEnabled;

  static const String mainChart = "main_chart";
  
  Indicator({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
    this.isEnabled = true,
  }) : super.from([]);

  @override
  factory Indicator.from(List<Object?> item) {
    if (item.length >= 5) {
      final jsonParameters = jsonDecode(item[3] as String);
      return Indicator(
        id: item[0] as int,
        name: item[1] as String,
        type: item[2] as String,
        parameters: jsonParameters,
        isEnabled: (item[4] as bool),
      );
    }
    return defaultIndicator();
  }

  factory Indicator.fromMap(Map<String, dynamic> item) {
    return Indicator(
      id: item['id'] as int? ?? -1,
      name: item['name'] as String? ?? '',
      type: item['type'] as String? ?? '',
      parameters: item['parameters'] as Map<String, dynamic>? ?? {},
      isEnabled: item['is_enabled'] as bool? ?? true
    );
  }

  @override
  Map<String, dynamic> toMap() =>   {
    'id': id,
    'name': name,
    'type': type,
    'parameters': parameters,
    'is_enabled': isEnabled,
  };

  @override
  String toString() => name;

  static Indicator defaultIndicator() {
    return Indicator(
      id: -1,
      name: '-',
      type: '-',
      parameters: {mainChart: false},
      isEnabled: false
    );
  }

  Indicator copyWith(String? newName, String? newType, bool? isEnabled, bool? isMainChart) {
    parameters[mainChart] = isMainChart ?? parameters[mainChart];
    return Indicator(
        id: id,
        name: newName ?? name,
        type: newType ?? type,
        parameters: parameters,
        isEnabled: isEnabled ?? this.isEnabled);
  }
  
  bool isDefault() {
    return id == -1 && name == '-';
  }

  bool isMainChart() {
    return parameters["_mainChart"] ?? false;
  }
}
