import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/multi_chart_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/asset_config.dart';
import '../model/results/indicator/price_result.dart';
import '../providers/load_database_provider.dart';
import '../providers/model_config.dart';
import '../providers/price_controller.dart';
import '../providers/assets_utilities.dart';
import '../providers/price_importer_csv.dart';
import '../widgets/dialogs/asset_dialog.dart';
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
    final assets = ref.watch(sortedAssetsProvider);
    final details = ref.watch(assetPriceDetailsProvider());
    final accounts = ref.watch(userAccountsProvider);
    return Shrinkable(
      title: "Index Prices",
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon:const Icon(Icons.refresh),
                  onPressed: () async {
                    final assetsToRefresh = assets.where((asset) => _refreshingIds.contains(asset.id)).toList();
                    try {
                      if (accounts.isEmpty) throw Exception('No accounts selected');
                      for (final asset in assetsToRefresh) {
                        final importer = ref.watch(priceImporterProvider(CacheKeyType.priceCache).notifier);
                        final importedPrices = await importer.importFromCsv(asset);
                        ref.read(priceControllerProvider().notifier).importAssetPrices(asset, importedPrices);
                      }
                      // ref.read(refreshAssetPricesProvider(accounts[0], assetsToRefresh).future);
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
                      }
                    } finally {
                      ref.read(refreshAllDetailsProvider.future);
                      if (mounted) {
                        setState(() {
                          _refreshingIds.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Refreshed ${assetsToRefresh.length} assets")),
                          );
                        });
                      }
                    }
                  },
                  label: const Text("Refresh All"),
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () => _handleAddAsset(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add asset'),
                ),
              ),
            ],
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

              return Shrinkable(title: asset.symbol,
                body: Card(
                  child: ListTile(
                    dense: true,
                    title: Text(asset.symbol),
                    subtitle: Text(detailText, style: const TextStyle(fontSize: 11)),
                    trailing: _buildTrailingActions(context, asset, isRefreshing),
                  )),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context, AssetConfig asset, bool isRefreshing) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifierAssetPrice = ref.watch(priceControllerProvider().notifier);

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
          icon: const Icon(Icons.download, size: 18),
          tooltip: 'Download ${asset.symbol} historical data',
          onPressed: () => _handleDownload(context, ref, asset)
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Edit Asset',
          onPressed: () => showAsset(context, asset, (newAsset) async {
            if (newAsset != null) {
              await ref.read(modelConfigProvider.notifier).update<AssetConfig>(
                  AssetConfigSchema(), newAsset);
              await ref.read(refreshAllDetailsProvider.future);
            }
          }),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: colorScheme.error, size: 18),
          tooltip: 'Delete History',
          onPressed: () => _handleDelete(context, ref, asset),
        ),
      ],
    );
  }

  Future<void> _handleAddAsset(BuildContext context, WidgetRef ref) async {
    showAsset(context, AssetConfig.defaultAsset(), (newAsset) async {
      if (newAsset != null) {
        await ref.read(modelConfigProvider.notifier).save<AssetConfig>(
            AssetConfigSchema(), newAsset);

        ref.read(refreshAllDetailsProvider.future);
      }
    });
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
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(removeMultiChartByProvider(CacheKeyType.analysisCache, asset).future);
      await ref.read(priceControllerProvider().notifier).deleteAssetAll(IndexPriceSchema(), asset);
      await ref.read(modelConfigProvider.notifier).removeAsset(asset);
      await ref.read(refreshAllDetailsProvider.future);
    }
  }

  void _handleDownload(BuildContext context, WidgetRef ref, AssetConfig asset) async {
    if (asset.links.isEmpty) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No links configured for this asset')),
        );
      }
      return;
    }

    for (final url in asset.links) {
      if (await canLaunchUrl(url)) {
        final result = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (result) {
          _refreshingIds.add(asset.id);
        }
        return;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch links for ${asset.symbol}')),
      );
    }
  }
}
