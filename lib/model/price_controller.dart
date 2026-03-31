import 'package:flutter/cupertino.dart';
import 'package:invest_agent/model/index_price.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';
import '../utils/database_helper.dart';
import 'asset_config.dart';

part 'price_controller.g.dart';

@immutable
class PriceControllerState {
  final List<IndexPrice> cache;

  const PriceControllerState({this.cache = const []});
  PriceControllerState copyWith(List<IndexPrice>? cache) {
    return PriceControllerState(cache: cache ?? this.cache);
  }
  
  List<IndexPrice> getItems() => cache;
}

@riverpod
class PriceController extends _$PriceController {
  @override
  PriceControllerState build() {
    ref.listen(databaseHelperProvider, (previous, next) {
      next.whenData((db) async {
        try {
          await db.createCache(IndexPriceSchema());
        } catch (e) {
          debugPrint('IndexPriceManager Init Error: $e');
        }
      });
    }, fireImmediately: true);

    return const PriceControllerState();
  }

  Future<DatabaseHelper> _getDb() async {
    return await ref.read(databaseHelperProvider.future);
  }

  Future<List<IndexPrice>> _fetchAndSet(Future<String> Function() queryBuilder) async {
    try {
      final db = await _getDb();
      final items = await db.useConnection<List<IndexPrice>>((con) async {
        final sql = await queryBuilder();
        final queryResults = await con.query(sql);
        // Using IndexPrice.from directly or via a registry if you have one
        return queryResults.fetchAll().map((row) => IndexPrice.from(row)).toList();
      });

      state = state.copyWith(items);
      return items;
    } catch (e) {
      debugPrint('PriceController Error: $e');
      return [];
    }
  }

  Future<void> _updateAndSet(Future<String> Function() execBuilder) async {
    try {
      final db = await _getDb();
      await db.transaction<void>((con) async {
        final sql = await execBuilder();
        await con.execute(sql);
      });
    } catch (e) {
      debugPrint('PriceController Error: $e');
    }
  }


  Future<T> _queryValue<T>(Future<String> Function() queryBuilder, T defaultValue) async {
    try {
      final db = await _getDb();
      return await db.useConnection<T>((con) async {
        final sql = await queryBuilder();
        final results = await con.query(sql);
        final row = results.fetchOne();
        return (row?[0] as T?) ?? defaultValue;
      });
    } catch (e) {
      debugPrint('PriceController Query Error: $e');
      return defaultValue;
    }
  }

  Future<List<IndexPrice>> fetchOne(IndexPriceSchema schema, IndexPrice price) =>
      _fetchAndSet(() async => schema.readOne(price));

  Future<List<IndexPrice>> fetchAll(IndexPriceSchema schema) =>
      _fetchAndSet(() async => schema.readAll);

  Future<List<IndexPrice>> fetchDateRange(IndexPriceSchema schema, AssetConfig asset, DateTime begin, DateTime end) {
    final actualBegin = begin.isBefore(end) ? begin : end;
    final actualEnd = begin.isBefore(end) ? end : begin;
    return _fetchAndSet(() async => schema.readDateRange(asset, actualBegin, actualEnd));
  }

  Future<List<IndexPrice>> fetchUntilDate(IndexPriceSchema schema, AssetConfig asset, DateTime date) =>
      _fetchAndSet(() async => schema.readUntilDate(asset, date));

  Future<List<IndexPrice>> fetchAfterDate(IndexPriceSchema schema, AssetConfig asset, DateTime date) =>
      _fetchAndSet(() async => schema.readAfterDate(asset, date));

  Future<void> save(IndexPriceSchema schema, IndexPrice item) async {
    await _updateAndSet(() async => schema.saveOne(item));
  }

  Future<void> update(IndexPriceSchema schema, IndexPrice item) async {
    await _updateAndSet(() async => schema.updateOne(item));
    // await _fetchAndSet(() async => schema.newestDate(item));;
  }

  Future<void> delete(IndexPriceSchema schema, IndexPrice item) async {
    await  _updateAndSet(() async => schema.deleteOne(item));;
  }

  Future<void> deleteAll(IndexPriceSchema schema) async {
    await _updateAndSet(() async => schema.deleteAll);
  }

  Future<void> deleteAssetAll(IndexPriceSchema schema, AssetConfig asset,) async {
    await _updateAndSet(() async => schema.deleteAssetAll(asset));
  }

  Future<DateTime> oldestDate(IndexPriceSchema schema, AssetConfig asset) async {
    final val = await _queryValue(() async => schema.oldestDate(asset), null);
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  Future<DateTime> newestDate(IndexPriceSchema schema, AssetConfig asset) async {
    final val = await _queryValue(() async => schema.newestDate(asset), null);
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  Future<int> count(IndexPriceSchema schema, AssetConfig asset, DateTime begin, DateTime end) =>
      _queryValue(() async => schema.readCount(asset, begin, end), 0);

  Future<String> assetPricesDetails(IndexPriceSchema schema, AssetConfig asset) async {
    try {
      final oldest = await oldestDate(schema, asset);
      final newest = await newestDate(schema, asset);
      final countValue = await count(schema, asset, oldest, newest);

      final oldestStr = oldest.toIso8601String().split('T')[0];
      final newestStr = newest.toIso8601String().split('T')[0];

      return 'Oldest: $oldestStr, Newest: $newestStr, Count: $countValue';
    } catch (e) {
      debugPrint('PriceController Error: $e');
      return 'No data or error';
    }
  }
}
