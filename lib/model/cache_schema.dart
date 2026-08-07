import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum CacheParam { edit, visible, type, value }
enum CacheParamType { int, double, string, color }
typedef CacheUniqueKey = int;

abstract class CacheSchema {
  String get createKey;
  String get create;
  String get readAll;
  String get deleteAll;

  String deleteOne(Cache cache);
  String saveOne(Cache cache);
  String readOne(Cache cache);
  String updateOne(Cache cache);
}

abstract class Cache extends Equatable {
  const Cache.from(List<Object?> item);
  Map<String, dynamic> toMap();
  @override
  String toString();

  static bool isEditable(dynamic parameterValue) {
    if (parameterValue is Map) {
      return parameterValue[CacheParam.edit.name]?.toString() == "1";
    }
    return true;
  }
  static bool isVisible(dynamic parameterValue) {
    if (parameterValue is Map) {
      return parameterValue[CacheParam.visible.name]?.toString() == "1";
    }
    return true;
  }
  static bool hasVisibilityOption(dynamic parameterValue) {
    if (parameterValue is Map) {
      return parameterValue.containsKey(CacheParam.visible.name);
    }
    return false;
  }
  static CacheParamType? getParameterType(dynamic parameterValue) {
    if (parameterValue is Map) {
      final typeStr = parameterValue[CacheParam.type.name]?.toString();
      return CacheParamType.values.firstWhereOrNull((e) => e.name == typeStr);
    }
    return null;
  }
  static dynamic getParameterValue(dynamic parameterValue) {
    if (parameterValue is Map) {
      return parameterValue[CacheParam.value.name];
    }
    if (parameterValue is List && parameterValue.isNotEmpty) {
      return parameterValue.first;
    }
    return parameterValue;
  }
  static dynamic updateParameterValue(dynamic oldParameterValue, dynamic newValue) {
    if (oldParameterValue is Map) {
      final newMap = Map<String, dynamic>.from(oldParameterValue);
      newMap[CacheParam.value.name] = newValue.toString();
      return newMap;
    }
    if (oldParameterValue is List) {
      final list = List<dynamic>.from(oldParameterValue);
      final val = newValue.toString();
      if (list.contains(val)) {
        list.remove(val);
        list.insert(0, val);
      }
      return list;
    }
    return newValue;
  }
  static dynamic updateParameterAttr(dynamic oldParameterValue,
      CacheParam attr,
      dynamic newValue) {
    if (oldParameterValue is Map) {
      final newMap = Map<String, dynamic>.from(oldParameterValue);
      newMap[attr.name] = newValue.toString();
      return newMap;
    }
    return oldParameterValue;
  }
  static dynamic getSelectedValue(Map<String, dynamic> parameters, String key) {
    final param = parameters[key];
    if (param == null) return null;
    return getParameterValue(param);
  }

  static dynamic normalizeKey(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((e) => e.toString()).toList()..sort();
      return {
        for (final k in sortedKeys) k: normalizeKey(value[k])
      };
    } else if (value is List) {
      if (value.length == 1) return normalizeKey(value[0]);
      return value.map(normalizeKey).toList();
    } else if (value is num) {
      return value.toDouble();
    }
    return value;
  }
}