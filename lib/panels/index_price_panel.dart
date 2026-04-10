import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _isRefreshingAll = false;
  final Set<int> _refreshingIds = {};

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(useAssetsProvider);
    final details = ref.watch(assetPriceDetailsProvider);
    // TODO: selected accounts
    final accounts = ref.watch(userAccountsProvider);
    // final fromDate = ref.watch(fromDateProvider);
    // final toDate = ref.watch(toDateProvider);
    // final symbols = ref.watch(symbolsProvider);
    // final limit = ref.watch(limitProvider);
    // final offset = ref.watch(offsetProvider);

    return Shrinkable(
      title: "Index Prices",
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: _isRefreshingAll 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              onPressed: _isRefreshingAll ? null : () async {
                setState(() => _isRefreshingAll = true);
                try {
                  // final validAssets = assets.where((a) => !a.isDefault()).toList();
                  // await ref.read(priceControllerProvider.notifier)
                  //     .refreshAssetPrices(validAssets, MarketStackType.eod);
                  //
                  // if (context.mounted) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('All asset prices updated')),
                  //   );
                  // }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update all assets: $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isRefreshingAll = false);
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: isRefreshing 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.read_more, color: Colors.lightGreen, size: 18),
                        onPressed: isRefreshing ? null : () async {
                          setState(() => _refreshingIds.add(asset.id));
                          try {
                            if (accounts.isEmpty) throw Exception('No accounts selected');
                            final apikey = await ref.read(modelConfigProvider.notifier).getAccountSecrets(accounts[0]).then((value) => value['apiKey']);
                            final fromDate = await ref.read(priceControllerProvider.notifier).newestDate(IndexPriceSchema(), asset);
                            final request = MarketStackRequest.fromEod(
                                apiKey: apikey!,
                                fromDate: fromDate,
                                symbols: ['${asset.symbol}${asset.stockExchange.suffix}'],
                                exchange: asset.stockExchange.code);

                            await ref.read(priceControllerProvider.notifier).refreshAssetPrices([asset], request);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Updated ${asset.symbol} prices')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update ${asset.symbol}: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _refreshingIds.remove(asset.id));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text('Delete all price data for ${asset.symbol}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref.read(priceControllerProvider.notifier).deleteAssetAll(IndexPriceSchema(), asset);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
