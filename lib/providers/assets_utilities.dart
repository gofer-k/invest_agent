import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/asset_config.dart';
import '../model/index_price.dart';
import 'price_controller.dart';

part 'assets_utilities.g.dart';

@riverpod
Future<Map<DateTimeRange, List<AssetConfig>>> assetsByTimeSpan(
    Ref ref, List<AssetConfig> assets) async {
  final notifier = ref.watch(priceControllerProvider.notifier);
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
