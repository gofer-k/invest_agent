abstract class Cache {
  String createKey();
  String create();
  String deleteOne();
  String saveOne();
  String readOne();
  String? updateOne();
  String readAll();
  String deleteAll();

  Cache.from(List<Object?> item);
  Map<String, dynamic> toMap();
}