import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/user_account.dart';

import '../model/asset_config.dart';
import '../model/index_price.dart';
import '../model/trading_request.dart';
import '../providers/model_config.dart';
import '../providers/price_controller.dart';
import '../widgets/utils/shrinkable.dart';

class IndexPricePanel extends ConsumerStatefulWidget {
  const IndexPricePanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPricePanelState();
}

class _IndexPricePanelState extends ConsumerState<IndexPricePanel> {
  bool _selectedAssets = false;
  final Set<int> _refreshingIds = {};

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(useAssetsProvider);
    final details = ref.watch(assetPriceDetailsProvider);
    // TODO: selected accounts
    final accounts = ref.watch(userAccountsProvider);
    return Shrinkable(
      title: "Index Prices",
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon:const Icon(Icons.refresh),
              onPressed: () async {
                final assetsToRefresh = assets.where((asset) => _refreshingIds.contains(asset.id)).toList();
                int refreshedNum = assetsToRefresh.length;
                try {
                  if (accounts.isEmpty) throw Exception('No accounts selected');

                  refreshedNum = min(await refreshAssetPrices(accounts[0], assetsToRefresh), assetsToRefresh.length);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated $refreshedNum assets')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update ${assetsToRefresh.length} assets: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() {
                    // TODO: improve refresh all
                    // _refreshingIds.clear();
                    _selectedAssets = _refreshingIds.isNotEmpty;
                  });
                }
              },
              label: const Text("Refresh All"),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              if (asset.isDefault()) return const SizedBox.shrink();
              
              final isRefreshing = _refreshingIds.contains(asset.id);
              final detailText = details[asset.id] ?? 'No data available';

              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(asset.symbol),
                  subtitle: Text(detailText, style: const TextStyle(fontSize: 11)),
                  trailing: _buildTrailingActions(context, asset, isRefreshing),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context, AssetConfig asset, bool isRefreshing) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRefreshing) ...[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, size: 18),
            tooltip: 'Cancel Refresh',
            onPressed: () {
              final notifier = ref.read(priceControllerProvider.notifier);
              final request = notifier.getRequestForAsset(asset);
              if (request != null) {
                notifier.cancelRemoteRequest(request);
                dev.log('User cancelled request for ${asset.symbol}');
              }
              setState(() =>  _refreshingIds.remove(asset.id));
            },
          ),
        ] else ...[
          Checkbox.adaptive(value: _refreshingIds.contains(asset.id), onChanged: (value) {
            if (value == null) return;
            setState(() {
              if (value == true) {
                _refreshingIds.add(asset.id);
              } else {
                _refreshingIds.remove(asset.id);
              }
            });
          }),
          // IconButton(
          //   icon: Icon(Icons.read_more, color: Colors.lightGreen, size: 18),
          //   tooltip: 'Refresh Prices',
          //   onPressed: () => _handleRefresh(context, asset),
          // ),
          IconButton(
            icon: Icon(Icons.delete, color: colorScheme.error, size: 18),
            tooltip: 'Delete History',
            onPressed: () => _handleDelete(context, ref, asset),
          ),
        ],
      ],
    );
  }
  //
  // Future<void> _handleRefresh(BuildContext context, AssetConfig asset) async {
  //   final accounts = ref.read(userAccountsProvider);
  //   if (accounts.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No accounts selected')),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _refreshingIds.add(asset.id));
  //   try {
  //     await refreshAssetPrices(accounts[0], [asset]);
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Updated ${asset.symbol} prices')),
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to update ${asset.symbol}: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _refreshingIds.remove(asset.id));
  //   }
  // }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, AssetConfig asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete all price data for ${asset.symbol}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(priceControllerProvider.notifier).deleteAssetAll(IndexPriceSchema(), asset);
    }
  }

  AssetsByExchange assetsByExchange(List<AssetConfig> assets) {
    return assets.fold<Map<String, List<AssetConfig>>>({}, (map, asset) {
      map.putIfAbsent(asset.stockExchange.code, () => []).add(asset);
      return map;
    });
  }

  Future<Map<DateTimeRange, List<AssetConfig>>>
  assetsByTimeSpan(List<AssetConfig> assets) async {
    final notifier = ref.read(priceControllerProvider.notifier);
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
    final Map<DateTimeRange, List<AssetConfig>> groupedAssets = {};
    for (final result in results) {
      groupedAssets.putIfAbsent(result.range, () => []).add(result.asset);
    }
    return groupedAssets;
  }

  Future<int> refreshAssetPrices(UserAccount account, List<AssetConfig> assets) async {
    int refreshedAssets = 0;
    final secrets = await ref.read(modelConfigProvider.notifier).getAccountSecrets(account);
    final apikey = secrets['apiKey'];
    final groupAssetsByExchange = assetsByExchange(assets);

    for (final entry in groupAssetsByExchange.entries) {
      final exchange = entry.key;
      final groupedAssets = entry.value;

      final groupAssetsByTimeSpan = await assetsByTimeSpan(groupedAssets);
      final bulkRequests = groupAssetsByTimeSpan.entries.map((e) {
        return MarketStackRequest.fromEod(
          apiKey: apikey!,
          fromDate: e.key.start,
          symbols: groupedAssets.map((a) => '${a.symbol}${a.stockExchange.suffix}').toList(),
          exchange: exchange);
      }).toList();

      for (final request in bulkRequests) {
        final num = await ref.read(priceControllerProvider.notifier).refreshAssetPrices(groupedAssets, request);
        refreshedAssets += num;
      }
    }

    dev.log('Refreshed assets $refreshedAssets');
    return refreshedAssets;
  }

  Future<void> refreshAllDetails() async {}
}
