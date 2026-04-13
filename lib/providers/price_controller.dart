import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/index_price.dart';
import 'package:invest_agent/model/trading_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'load_database_provider.dart';
import '../utils/database_helper.dart';
import '../model/asset_config.dart';
import 'investing_data_client.dart';

part 'price_controller.g.dart';

@immutable
class PriceControllerState {
  final List<IndexPrice> cache;
  final Map<int, String> assetDetails;

  const PriceControllerState({this.cache = const [], this.assetDetails = const {}});
  
  PriceControllerState copyWith({List<IndexPrice>? cache, Map<int, String>? assetDetails}) {
    return PriceControllerState(
      cache: cache ?? this.cache,
      assetDetails: assetDetails ?? this.assetDetails,
    );
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
          // if (ref.mounted) {
            await refreshAllDetails();
          // }
        } catch (e) {
          if (e.toString().contains('disposed')) return;
          dev.log('IndexPriceManager Init Error: $e');
        }
      });
    }, fireImmediately: true);

    return const PriceControllerState();
  }

  Future<DatabaseHelper> _getDb() async {
    if (!ref.mounted) {
      throw Exception('Provider disposed');
    }
    return await ref.read(databaseHelperProvider.future);
  }

  Future<List<IndexPrice>> _fetchAndSet(Future<String> Function() queryBuilder) async {
    try {
      final db = await _getDb();
      final items = await db.useConnection<List<IndexPrice>>((con) async {
        final sql = await queryBuilder();
        final queryResults = await con.query(sql);
        return queryResults.fetchAll().map((row) => IndexPrice.from(row)).toList();
      });

      if (!ref.mounted) return items;
      state = state.copyWith(cache: items);
      return items;
    } catch (e) {
      if (e.toString().contains('disposed')) return [];
      dev.log('PriceController Error: $e');
      return [];
    }
  }

  Future<void> _updateAndSet(Future<String> Function() execBuilder, {IndexPrice? item, bool isDelete = false}) async {
    try {
      final db = await _getDb();
      // await db.saveOne(IndexPriceSchema(), item);
      await db.transaction<void>((con) async {
        final sql = await execBuilder();
        await con.execute(sql);
      });

      if (ref.mounted) {
        // Update cache incrementally
        if (item != null) {
          final currentCache = List<IndexPrice>.from(state.cache);
          if (isDelete) {
            currentCache.removeWhere((e) => e.id == item.id);
          } else {
            final index = currentCache.indexWhere((e) => e.id == item.id && item.id != 0);
            if (index != -1) {
              currentCache[index] = item;
            } else {
              // For new items (id=0), we might still want to fetchAll
              // once to get the DB-generated ID, but for tests we can just add it.
              currentCache.insert(0, item);
            }
          }
          state = state.copyWith(cache: currentCache);
        }
      }
    } catch (e) {
      dev.log('PriceController Error: $e');
    }
  }

  Future<T> _queryValue<T>(Future<String> Function() queryBuilder, T defaultValue) async {
    try {
      if (!ref.mounted) return defaultValue;
      final db = await _getDb();
      return await db.useConnection<T>((con) async {
        final sql = await queryBuilder();
        final results = await con.query(sql);
        final row = results.fetchOne();
        return (row?[0] as T?) ?? defaultValue;
      });
    } catch (e) {
      if (e.toString().contains('disposed')) return defaultValue;
      dev.log('PriceController Query Error: $e');
      return defaultValue;
    }
  }

  Future<void> refreshAllDetails() async {
    try {
      if (!ref.mounted) return;
      final db = await _getDb();
      final schema = IndexPriceSchema();
      final details = await db.useConnection<Map<int, String>>((con) async {
        final results = await con.query(schema.allAssetDetails);
        final Map<int, String> map = {};
        for (final row in results.fetchAll()) {
          final assetId = row[0] as int;
          final oldest = row[1];
          final newest = row[2];
          final count = row[3];
          
          final oldestStr = oldest is DateTime ? oldest.toIso8601String().split('T')[0] : oldest.toString().split(' ')[0];
          final newestStr = newest is DateTime ? newest.toIso8601String().split('T')[0] : newest.toString().split(' ')[0];
          
          map[assetId] = 'Oldest: $oldestStr, Newest: $newestStr, Count: $count';
        }
        return map;
      });

      if (ref.mounted) {
        state = state.copyWith(assetDetails: details);
      }
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      dev.log('Error refreshing all details: $e');
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
    await _updateAndSet(() async => schema.saveOne(item), item: item);
  }

  Future<void> update(IndexPriceSchema schema, IndexPrice item) async {
    await _updateAndSet(() async => schema.updateOne(item), item: item);
  }

  Future<void> delete(IndexPriceSchema schema, IndexPrice item) async {
    await  _updateAndSet(() async => schema.deleteOne(item), item: item, isDelete: true);
  }

  Future<void> deleteAll(IndexPriceSchema schema) async {
    await _updateAndSet(() async => schema.deleteAll);
  }

  Future<void> deleteAssetAll(IndexPriceSchema schema, AssetConfig asset) async {
    await _updateAndSet(() async => schema.deleteAssetAll(asset));
  }

  Future<DateTime> oldestDate(IndexPriceSchema schema, AssetConfig asset) async {
    final val = await _queryValue<Object?>(() async => schema.oldestDate(asset), null);
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  Future<DateTime> newestDate(IndexPriceSchema schema, AssetConfig asset) async {
    final val = await _queryValue<Object?>(() async => schema.newestDate(asset), null);
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  Future<int> count(IndexPriceSchema schema, AssetConfig asset, DateTime begin, DateTime end) =>
      _queryValue(() async => schema.readCount(asset, begin, end), 0);

  Future<int> refreshAssetPrices(List<AssetConfig> assets, RemoteRequest request) async {
    int result = 0;
    try {
      final db = await _getDb();
      final schema = IndexPriceSchema();
      
      final client = ref.read(investingDataClientProvider(request).notifier);
      final responseMap = await client.getRequest();

      await db.transaction((con) async {
        for (final item in responseMap) {
          final respond = MarketStackRespond.fromEod(item);
          final asset = assets.firstWhere((a) => a.symbol == respond.symbol,
              orElse: () => AssetConfig.defaultAsset());
          if (asset.isDefault()) {
            dev.log("Asset not found: ${respond.symbol} in the cache");
            continue;
          }
          final price = IndexPrice(
            id: 0,
            assetId: asset.id,
            dateTime: respond.timestamp,
            openPrice: respond.open,
            closePrice: respond.close,
            highPrice: respond.high,
            lowPrice: respond.low,
            volume: respond.volume,
          );
          await con.execute(schema.saveOne(price));
          result++;
        }
      });

      if (ref.mounted) {
        await refreshAllDetails();
      }
    } catch (e) {
      dev.log('Error refreshing prices for ${request.resource.toString()}: $e');
      return 0;
    }
    return result;
  }
}

@riverpod
Map<int, String> assetPriceDetails(Ref ref) {
  return ref.watch(priceControllerProvider.select((s) => s.assetDetails));
}
