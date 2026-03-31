import 'package:flutter/cupertino.dart';
import 'package:invest_agent/model/index_price.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';
import '../utils/database_helper.dart';

part 'price_controller.g.dart';

/// The state for IndexPriceManager, holding in-memory cache of different models.'
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

  Future<List<IndexPrice>> fetchDateRange(IndexPriceSchema schema, DateTime begin, DateTime end) {
    final actualBegin = begin.isBefore(end) ? begin : end;
    final actualEnd = begin.isBefore(end) ? end : begin;
    return _fetchAndSet(() async => schema.readDateRange(actualBegin, actualEnd));
  }

  Future<List<IndexPrice>> fetchUntilDate(IndexPriceSchema schema, DateTime date) =>
      _fetchAndSet(() async => schema.readUntilDate(date));

  Future<List<IndexPrice>> fetchAfterDate(IndexPriceSchema schema, DateTime date) =>
      _fetchAndSet(() async => schema.readAfterDate(date));

  Future<void> save(IndexPriceSchema schema, IndexPrice item) async {
    await _fetchAndSet(() async => schema.saveOne(item));
    // await _fetchAndSet(() async => schema.newestDate(item));
  }

  Future<void> update(IndexPriceSchema schema, IndexPrice item) async {
    await _fetchAndSet(() async => schema.updateOne(item));
    // await _fetchAndSet(() async => schema.newestDate(item));;
  }

  Future<void> delete(IndexPriceSchema schema, IndexPrice item) async {
    await  _fetchAndSet(() async => schema.deleteOne(item));;
    // await  _fetchAndSet(() async => schema.newestDate(item));;
  }

  Future<void> deleteAll(IndexPriceSchema schema) async {
    await _fetchAndSet(() async => schema.deleteAll);
  }

  Future<DateTime> oldestDate(IndexPriceSchema schema, IndexPrice item) =>
      _queryValue(() async => schema.oldestDate(item), DateTime.now());

  Future<DateTime> newestDate(IndexPriceSchema schema, IndexPrice item) =>
      _queryValue(() async => schema.newestDate(item), DateTime.now());

  Future<int> count(IndexPriceSchema schema, DateTime begin, DateTime end) =>
      _queryValue(() async => schema.readCount(begin, end), 0);
}