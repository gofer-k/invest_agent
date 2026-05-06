import 'dart:convert';

import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/indicator_schema.dart';

/*
  Drawing features for trading data:
  - Label: [position, text]
  - Line chart: [begin, end, type(horizontal, vertical, any), color, width, style, label]
  - Rectangle: [leftTop, rightBotton, color, width, style, label]
 */
class DrawingSchema extends CacheSchema{
  static const String cacheName = "drawing";
  static const String sequenceName = "drawing_id_sequence";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $cacheName (
        id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
        indicator_id INTEGER,
        type: TEXT NOT NULL,            
        parameters TEXT, -- JSON string,
        UNIQUE(indicator_id, date),
        FOREIGN KEY (indicator_id) REFERENCES ${IndicatorSchema.tableName}(id)
    );      
  ''';

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $sequenceName START 1;";

  @override
  String get deleteAll => "DELETE FROM $cacheName;";

  @override
  String deleteOne(Cache cache) =>
      "DELETE FROM $cacheName WHERE id = ${(cache as DrawingFeature).id};";

  @override
  String get readAll => "SELECT * FROM $cacheName ORDER BY type;";

  @override
  String readOne(Cache cache) =>
    "SELECT * FROM $cacheName WHERE id = ${(cache as DrawingFeature).id};";

  @override
  String saveOne(Cache cache) {
    final drawing = cache as DrawingFeature;
    return '''
      INSERT INTO $cacheName 
      VALUES (
      nextval('$sequenceName'),
      ${drawing.indicatorId},
      '${drawing.type}',
      '${drawing.parameters}'
      ) ON CONFLICT(indicator_id, type) DO UPDATE SET
          parameters = excluded.parameters;
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final drawing = cache as DrawingFeature;
    return '''
      UPDATE $cacheName
      SET indicator_id = ${drawing.indicatorId},
          type = '${drawing.type}',
          parameters = '${drawing.parameters}'
      WHERE id = ${drawing.id};
    ''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingSchema && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DrawingFeature extends Cache {
  final int id;
  final int indicatorId;
  final String type;
  final Map<String, dynamic> parameters;

  DrawingFeature({
    required this.id,
    required this.indicatorId,
    required this.type,
    required this.parameters,
  }) : super.from([]);

  @override
  factory DrawingFeature.from(List<Object?> item) {
    final jsonParameters = jsonDecode(item[3] as String);
    return DrawingFeature(
      id: item[0] as int,
      indicatorId: item[1] as int,
      type: item[2] as String,
      parameters: jsonParameters);
  }

  @override
  Map<String, dynamic> toMap() =>
    {
      'id': id,
      'indicator_id': indicatorId,
      'type': type,
      'parameters': parameters,
    };

  @override
  String toString() => type;

  static DrawingFeature defaultDrawing() {
    return DrawingFeature(
      id: -1,
      indicatorId: -1,
      type: '',
      parameters: {});
  }

  bool isDefault() {
    return id == -1 && indicatorId == -1;
  }
}