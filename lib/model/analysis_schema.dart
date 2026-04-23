import 'dart:convert';
import 'dart:developer';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/model/cache_schema.dart';

class AnalysisEntry implements Cache {
  final int? id;
  final int userId; 
  final AnalysisRequest? request;
  final DateTime createdAt;

  AnalysisEntry({
    this.id,
    required this.userId,
    required this.request,
    required this.createdAt,
  });

  @override
  factory AnalysisEntry.from(List<Object?> item) {
    try {
      DateTime dateTime;
      var jsonObject = item[3];
      if (jsonObject is DateTime) {
        dateTime = jsonObject;
      } else {
        dateTime = DateTime.parse(jsonObject.toString());
      }
      return AnalysisEntry(
        id: item[0] as int?,
        userId: item[1] as int,
        request: AnalysisRequest.fromJson(jsonDecode(item[2] as String)),
        createdAt: dateTime);
    }
    catch (e) {
      throw Exception("Invalidate input data: $e");
    }
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'request_json': request != null ? jsonEncode(request?.toJson()) : null,
    'created_at': createdAt.toIso8601String(),
  };
}

class AnalysisSchema extends CacheSchema {
  static const String tableName = "analysis_cache";

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS analysis_cache_seq;";

  @override
  String get create => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY DEFAULT nextval('analysis_cache_seq'),
      user_id INTEGER,
      request_json TEXT,
      created_at TIMESTAMP
    );
  ''';

  @override
  String get readAll => "SELECT * FROM $tableName ORDER BY created_at DESC;";

  @override
  String saveOne(Cache cache) {
    final entry = cache as AnalysisEntry;
    final map = entry.toMap();
    try {
      final dateTime = DateTime.tryParse(map['created_at'])?.toIso8601String();
      return "INSERT INTO $tableName (user_id, request_json, created_at) "
          "VALUES (${map['user_id']}, '${map['request_json']}','$dateTime');";
    }
    catch (e) {
      log("Invalid date format: ${map['created_at']}");
    }
    return "";
  }

  @override
  String deleteOne(Cache cache) => "DELETE FROM $tableName WHERE id = ${(cache as AnalysisEntry).id};";

  @override
  String updateOne(Cache cache) {
     final entry = cache as AnalysisEntry;
     final map = entry.toMap();
     return "UPDATE $tableName SET request_json = '${map['request_json']}' WHERE id = ${entry.id};";
  }

  @override
  String readOne(Cache cache) => "SELECT * FROM $tableName WHERE id = ${(cache as AnalysisEntry).id};";
  
  @override
  String get deleteAll => "DELETE FROM $tableName;";

  @override
  bool operator ==(Object other) => other is AnalysisSchema;

  @override
  int get hashCode => tableName.hashCode;
}
