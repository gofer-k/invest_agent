import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/asset_config.dart';
import '../model/results/price_result.dart';
import '../model/trading_request.dart';
import '../model/user_account.dart';
import 'load_database_provider.dart';
import 'model_config.dart';
import 'price_controller.dart';

part 'assets_utilities.g.dart';

@riverpod
Future<Map<DateTimeRange, List<AssetConfig>>> assetsByTimeSpan(
    Ref ref, List<AssetConfig> assets, [CacheKeyType? cacheTYpe, bool? keepAlive]) async {
  final notifier = ref.watch(priceControllerProvider(cacheTYpe, keepAlive).notifier);
  final schema = IndexPriceSchema();
  
  final results = await Future.wait(assets.map((asset) async {
    // Fetch both dates in parallel for this specific asset
    final dates = await Future.wait([
      notifier.oldestDate(schema, asset),
      notifier.newestDate(schema, asset),
    ]);

    final start = DateUtils.dateOnly(dates[0]);
    final end = DateUtils.dateOnly(dates[1]);

    // Ensure start is not after end to avoid DateTimeRange assertion errors
    final validStart = start.isBefore(end) ? start : end;
    final validEnd = start.isBefore(end) ? end : start;

    return (asset: asset, range: DateTimeRange(start: validStart, end: validEnd));
  }));

  // Filter out time ranges that are too short (less than 5 seconds)
  results.removeWhere((r) => r.range.duration.inSeconds < 5);

  final Map<DateTimeRange, List<AssetConfig>> groupedAssets = {};
  for (final result in results) {
    groupedAssets.putIfAbsent(result.range, () => []).add(result.asset);
  }
  return groupedAssets;
}

@riverpod
Future<void> refreshAssetPrices(Ref ref, UserAccount account, List<AssetConfig> assets) async {
  final link = ref.keepAlive();
  try {
    final secrets = await ref.read(modelConfigProvider.notifier).getAccountSecrets(account);
    if (!ref.mounted) return;
    
    final apikey = secrets['apiKey'];
    final groupAssetsByExchange = assetsByExchange(assets);

    for (final entry in groupAssetsByExchange.entries) {
      final exchange = entry.key;
      final groupedAssets = entry.value;

      final groupAssetsByTimeSpan = await ref.read(assetsByTimeSpanProvider(groupedAssets).future);
      if (!ref.mounted) return;

      final bulkRequests = groupAssetsByTimeSpan.entries.map((e) {
        return MarketStackRequest.fromEod(
          apiKey: apikey!,
          fromDate: e.key.start,
          symbols: groupedAssets.map((a) => '${a.symbol}${a.stockExchange.suffix}').toList(),
          exchange: exchange,
          limit: 1000,
        );
      }).toList();

      for (final request in bulkRequests) {
        await ref.read(priceControllerProvider().notifier).refreshAssetPrices(groupedAssets, request);
        if (!ref.mounted) return;
      }
    }

    dev.log( '[${DateTime.now().toIso8601String()}] Refreshed assets');
  } finally {
    link.close();
  }
}

@riverpod
Future<void> refreshAllDetails(Ref ref) async {
  await ref.read(priceControllerProvider().notifier).refreshAllDetails();
}

AssetsByExchange assetsByExchange(List<AssetConfig> assets) {
  return assets.fold<Map<String, List<AssetConfig>>>({}, (map, asset) {
    map.putIfAbsent(asset.stockExchange.code, () => []).add(asset);
    return map;
  });
}
