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
  String get readAll => "SELECT * FROM $tableName;";

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
          is_enabled = ${config.isEnabled}
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

  Indicator({
    required this.id,
    required this.name,
    required this.type,
    required this.parameters,
    this.isEnabled = true,
  }) : super.from([]);

  @override
  factory Indicator.from(List<Object?> item) {
    final jsonParameters = jsonDecode(item[3] as String);
    return Indicator(
      id: item[0] as int,
      name: item[1] as String,
      type: item[2] as String,
      // parameters: item[3] as Map<String, dynamic>,
      parameters: jsonParameters,
      isEnabled: (item[4] as bool),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
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
      name: '',
      type: '',
      parameters: {},
      isEnabled: false,
    );
  }

  Indicator copyWith(bool isEnabled) => Indicator(
    id: this.id,
    name: this.name,
    type: this.type,
    parameters: this.parameters,
    isEnabled: isEnabled,
  );

  bool isDefault() {
    return id == -1 && name == '';
  }
}
