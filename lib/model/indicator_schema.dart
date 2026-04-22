import 'package:invest_agent/model/cache_schema.dart';
import 'dart:convert';

class IndicatorSchema implements CacheSchema {
  static const String tableName = "indicators";
  static const String sequenceName = "indicators_id_seq";

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $sequenceName START 1;";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      name TEXT NOT NULL,
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
      INSERT INTO $tableName (name, type, parameters, is_enabled)
      VALUES ('${config.name}', '${config.type}', '${jsonEncode(config.parameters)}', ${config.isEnabled});
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
}

class Indicator extends Cache {
  final int id;
  final String name;
  final String type; // SMA, EMA, RSI, etc.
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
    return Indicator(
      id: item[0] as int,
      name: item[1] as String,
      type: item[2] as String,
      parameters: jsonDecode(item[3] as String),
      isEnabled: (item[4] as int) == 1,
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
}