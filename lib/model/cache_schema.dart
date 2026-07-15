import 'package:equatable/equatable.dart';

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
}