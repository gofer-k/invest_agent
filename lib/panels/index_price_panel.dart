import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/asset_config.dart';
import '../model/index_price.dart';
import '../providers/model_config.dart';
import '../providers/price_controller.dart';
import '../providers/assets_utilities.dart';
import '../widgets/utils/shrinkable.dart';

class IndexPricePanel extends ConsumerStatefulWidget {
  const IndexPricePanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPricePanelState();
}

class _IndexPricePanelState extends ConsumerState<IndexPricePanel> {
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
                try {
                  if (accounts.isEmpty) throw Exception('No accounts selected');
                  ref.read(refreshAssetPricesProvider(accounts[0], assetsToRefresh).future);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated ${assetsToRefresh.length} assets')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update ${assetsToRefresh.length} assets: $e')),
                    );
                    dev.log("Failed to update ${assetsToRefresh.length} assets: $e'");
                  }
                } finally {
                  ref.read(refreshAllDetailsProvider.future);
                  if (mounted) {
                    setState(() => _refreshingIds.clear());
                    dev.log("Refreshed ${assetsToRefresh.length} assets");
                  }
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
    final notifierAssetPrice = ref.watch(priceControllerProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Stack(alignment: Alignment.center,
          children: [
            if (isRefreshing)
              const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            IconButton(
              icon: Icon(isRefreshing ? Icons.cancel : Icons.refresh, size: 18),
              tooltip: isRefreshing ? 'Cancel request' : 'Refresh Asset',
              onPressed: () {
                if (isRefreshing) {
                  final requestedAsset = notifierAssetPrice.getRequestForAsset(asset);
                  if (requestedAsset != null) {
                    notifierAssetPrice.cancelRemoteRequest(requestedAsset);
                    dev.log('[${DateTime.now().toIso8601String()}] User cancelled request for ${asset.symbol}');
                  }
                  setState(() =>  _refreshingIds.remove(asset.id));
                }
              },
            ),
          ]
        ),
        IconButton(
          icon: Icon(Icons.delete, color: colorScheme.error, size: 18),
          tooltip: 'Delete History',
          onPressed: () => _handleDelete(context, ref, asset),
        ),
      ],
    );
  }

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
}
