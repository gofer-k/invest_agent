abstract class CacheSchema {
  static String createKey() => throw UnimplementedError();
  static String create() => throw UnimplementedError();
  static String readAll() => throw UnimplementedError();
  static String deleteAll() => throw UnimplementedError();

  String deleteOne();
  String saveOne();
  String readOne();
  String? updateOne();

  CacheSchema.from(List<Object?> item);
  Map<String, dynamic> toMap();
}