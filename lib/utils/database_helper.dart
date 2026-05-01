import 'dart:async';
import 'dart:developer';

import 'package:dart_duckdb/dart_duckdb.dart';
import 'package:invest_agent/model/cache_registry.dart';
import '../model/cache_schema.dart';

/// A helper class to manage DuckDB connections with support for concurrency.
class DatabaseHelper {
  // Singleton
  // static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _db;
  final List<Connection> _cons = [];
  final Set<Connection> _inUse = {};
  final List<Completer<Connection>> _waiters = [];
  
  final String cacheFile;
  final int maxConnections;
  final bool readOnly;
  final Map<String, String> customSettings;

  Future<void>? _initFuture;

  /// [cacheFile] is the path to the database.
  /// [maxConnections] defines the size of the internal connection pool.
  /// [readOnly] allows opening the database even if another process (like DBeaver) has it open,
  /// provided that process is also in read-only mode or you only need to read.
  /// [settings] allows passing custom DuckDB configurations (e.g., {'threads': '4', 'access_mode': 'READ_ONLY'}).
  // factor DatabaseHelper(this._cacheFile, {
  //   int maxConnections = 5,
  //   bool readOnly = false,
  //   Map<String, String>? settings,
  // }) {
  //   if (_instance._cacheFile != cacheFile || _instance._readOnly != readOnly) {
  //     _instance.dispose();
  //     _instance._cacheFile = cacheFile;
  //     _instance._readOnly = readOnly;
  //   }
  //   _instance._maxConnections = maxConnections;
  //   _instance._customSettings = settings ?? {};
  //   return _instance;
  // }
  //
  // DatabaseHelper._internal();

  DatabaseHelper({required this.cacheFile,
    this.maxConnections = 5,
    this.readOnly = false,
    this.customSettings = const {},
  });

  Future<void> init() async {
    if (_db != null) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    try {
      final config = Map<String, String>.from(customSettings);
      if (readOnly) {
        config['access_mode'] = 'READ_ONLY';
      }

      _db = await duckdb.open(cacheFile, settings: config);
      
      // Pre-warm with at least one connection
      final conn = await duckdb.connect(_db!);
      _cons.add(conn);
    } catch (e) {
      _initFuture = null;
      if (e.toString().contains('Conflicting lock')) {
        log('DATABASE LOCK ERROR: The database file is currently locked by another process (e.g., DBeaver). '
            'Close the other application or open DatabaseHelper in read-only mode.');
      }
      rethrow;
    }
  }

  bool isConnected() {
    return _db != null;
  }

  /// Provides a connection to execute custom logic and automatically returns it to the pool.
  Future<T> useConnection<T>(Future<T> Function(Connection con) action) async {
    await init();
    final connection = await _acquireConnection();
    try {
      return await action(connection);
    } finally {
      _releaseConnection(connection);
    }
  }

  /// Executes multiple operations within a single database transaction.
  Future<T> transaction<T>(Future<T> Function(Connection con) action) async {
    if (readOnly) throw StateError('Cannot start a transaction in read-only mode.');
    
    return useConnection((con) async {
      await con.execute('BEGIN TRANSACTION');
      try {
        final result = await action(con);
        await con.execute('COMMIT');
        return result;
      } catch (e) {
        await con.execute('ROLLBACK');
        rethrow;
      }
    });
  }

  Future<Connection> _acquireConnection() async {
    // 1. Try to find an idle connection
    for (var c in _cons) {
      if (!_inUse.contains(c)) {
        _inUse.add(c);
        return c;
      }
    }

    // 2. If no idle connection and we haven't reached max, create a new one
    if (_cons.length < maxConnections) {
      try {
        final newConn = await duckdb.connect(_db!);
        _cons.add(newConn);
        _inUse.add(newConn);
        return newConn;
      } catch (e) {
        log('Error creating new connection: $e');
      }
    }

    // 3. Wait for a connection to become available
    final completer = Completer<Connection>();
    _waiters.add(completer);
    return completer.future;
  }

  void _releaseConnection(Connection conn) {
    if (_waiters.isNotEmpty) {
      final next = _waiters.removeAt(0);
      next.complete(conn);
    } else {
      _inUse.remove(conn);
    }
  }

  Database get db {
    if (_db == null) {
      throw StateError('DatabaseHelper not initialized. Call init() first.');
    }
    return _db!;
  }

  // --- CRUD OPERATIONS ---

  Future<void> createCache(CacheSchema schema) {
    return useConnection((con) async {
      await con.execute(schema.createKey);
      await con.execute(schema.create);
    });
  }

  Future<T?> fetchOne<T extends Cache>(CacheSchema schema, T cache) {
    return useConnection((con) async {
      final queryResult = (await con.query(schema.readOne(cache))).fetchOne();
      return queryResult != null ? CacheRegistry.create<T>(queryResult) : null;
    });
  }

  Future<List<T>> fetchAll<T extends Cache>(CacheSchema schema) {
    return useConnection((con) async {
      final queryResults = await con.query(schema.readAll);
      return queryResults.fetchAll().map((row) => CacheRegistry.create<T>(row)).toList();
    });
  }

  Future<void> saveOne<T extends Cache>(CacheSchema schema, T cache) {
    return useConnection((con) async {
      await con.execute(schema.saveOne(cache));
    });
  }

  Future<void> saveAll<T extends Cache>(CacheSchema schema, List<T> caches) {
    return useConnection((con) async {
      for (final cache in caches) {
        await con.execute(schema.saveOne(cache));
      }
    });
  }

  Future<void> updateOne<T extends Cache>(CacheSchema schema, T cache) {
    return useConnection((con) async {
      final query = schema.updateOne(cache);
      await con.execute(query);
    });
  }

  Future<void> updateAll<T extends Cache>(CacheSchema schema, List<T> caches) {
    return useConnection((con) async {
      for (final cache in caches) {
        final query = schema.updateOne(cache);
        await con.execute(query);
      }
    });
  }

  Future<void> deleteOne<T extends Cache>(CacheSchema schema, T cache) {
    return useConnection((con) async {
      await con.execute(schema.deleteOne(cache));
    });
  }

  Future<void> deleteAll<T extends Cache>(CacheSchema schema) {
    return useConnection((con) async {
      await con.execute(schema.deleteAll);
    });
  }

  void dispose() {
    for (var waiter in _waiters) {
      waiter.completeError(StateError('DatabaseHelper disposed'));
    }
    _waiters.clear();
    _inUse.clear();

    for (var con in _cons) {
      try {
        con.dispose();
      } catch (e) {
        log('Error disposing connection: $e');
      }
    }
    _cons.clear();

    try {
      _db?.dispose();
    } catch (e) {
      log('Error disposing database: $e');
    }

    _initFuture = null;
    _db = null;
  }
}
