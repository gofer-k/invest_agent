import 'package:dart_duckdb/dart_duckdb.dart';
import 'package:invest_agent/model/cache_registry.dart';
import '../model/cache_schema.dart';


class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _db;
  late Connection _con;
  late String cacheFile;
  bool _isInitialized = false;

  factory DatabaseHelper(String cacheFile) {
   _instance.cacheFile = cacheFile;
   return _instance;
  }

  DatabaseHelper._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    _db = await duckdb.open(cacheFile);
    _con = await duckdb.connect(_db);

    _isInitialized = true;
  }

  // --- CRUD OPERATIONS ---
  Future<void> createCache<T extends CacheSchema>() async {
    await _con.execute((T as dynamic).createKey);
    await _con.execute((T as dynamic).create);
  }

  Future<T?> fetchOne<T extends CacheSchema>(T cache) async {
    final queryResult = (await _con.query(cache.readOne())).fetchOne();
    return queryResult != null ? CacheRegistry.create<T>(queryResult) : null;
  }

  Future<List<T>> fetchAll<T extends CacheSchema>() async {
    final queryResults = (await _con.query((T as dynamic).readAll())).fetchAll();
    return queryResults.map((row) => CacheRegistry.create<T>(row)).toList();
  }

  Future<void> saveOne<T extends CacheSchema>(T cache) async {
    await _con.execute(cache.saveOne());
  }

  Future<void> saveAll<T extends CacheSchema>(List<T> caches) async {
    for (final cache in caches) {
      await _con.execute(cache.saveOne());
    }
  }

  Future<void> updateOne<T extends CacheSchema>(T cache) async {
    final query = cache.updateOne();
    if (query != null) {
      await _con.execute(query);
    }
  }

  Future<void> updateAll<T extends CacheSchema>(List<T> caches) async {
    for (final cache in caches) {
      final query = cache.updateOne();
      if (query != null) {
        await _con.execute(query);
      }
    }
  }

  Future<void> deleteOne<T extends CacheSchema>(T cache) async{
    await _con.execute(cache.deleteOne());
  }

  Future<void> deleteAll<T extends CacheSchema>() async{
    await _con.execute((T as dynamic).deleteAll());
  }

  void dispose() {
    _con.dispose();
    _db.dispose();
  }
}
