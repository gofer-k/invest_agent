import 'package:dart_duckdb/dart_duckdb.dart';
import 'package:invest_agent/model/cache_registry.dart';
import '../model/cache_schema.dart';


class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _db;
  Connection? _con;
  late String cacheFile;

  Future<void>? _initFuture;

  factory DatabaseHelper(String cacheFile) {
   _instance.cacheFile = cacheFile;
   return _instance;
  }

  DatabaseHelper._internal();

  Future<void> init() async {
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    try {
      _db = await duckdb.open(cacheFile);
      _con = await duckdb.connect(_db!);
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }

  Connection get con {
    if (_con == null) {
      throw StateError('DatabaseHelper must be initialized by calling await init() before use.');
    }
    return _con!;
  }

  Database get db {
    if (_db == null) {
      throw StateError('DatabaseHelper must be initialized by calling await init() before use.');
    }
    return _db!;
  }

  // --- CRUD OPERATIONS ---
  Future<void> createCache(CacheSchema schema) async {
    await con.execute(schema.createKey);
    await con.execute(schema.create);
  }

  Future<T?> fetchOne<T extends Cache>(CacheSchema schema, T cache) async {
    final queryResult = (await con.query(schema.readOne(cache))).fetchOne();
    return queryResult != null ? CacheRegistry.create<T>(queryResult) : null;
  }

  Future<List<T>> fetchAll<T extends Cache>(CacheSchema schema) async {
    final queryResults = await con.query(schema.readAll);
    return queryResults.fetchAll().map((row) => CacheRegistry.create<T>(row)).toList();
  }

  Future<void> saveOne<T extends Cache>(CacheSchema schema, T cache) async {
    await con.execute(schema.saveOne(cache));
  }

  Future<void> saveAll<T extends Cache>(CacheSchema schema, List<T> caches) async {
    for (final cache in caches) {
      await con.execute(schema.saveOne(cache));
    }
  }

  Future<void> updateOne<T extends Cache>(CacheSchema schema, T cache) async {
    final query = schema.updateOne(cache);
     await con.execute(query);
  }

  Future<void> updateAll<T extends Cache>(CacheSchema schema, List<T> caches) async {
    for (final cache in caches) {
      final query = schema.updateOne(cache);
      await con.execute(query);
    }
  }

  Future<void> deleteOne<T extends Cache>(CacheSchema schema, T cache) async{
    await con.execute(schema.deleteOne(cache));
  }

  Future<void> deleteAll<T extends Cache>(CacheSchema schema) async{
    await con.execute(schema.deleteAll);
  }

  void dispose() {
    _con?.dispose();
    _db?.dispose();
    _initFuture = null;
    _con = null;
    _db = null;
  }
}
