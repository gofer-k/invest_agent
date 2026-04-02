import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/model_config.dart';
import '../model/portfolio_config.dart';
import '../providers/load_database_provider.dart';
import '../widgets/portfolio_config_dialog.dart';
import '../widgets/utils/shrinkable.dart';

class PortfolioPanel extends ConsumerStatefulWidget {
  const PortfolioPanel({super.key});

  @override
  ConsumerState<PortfolioPanel> createState() => _PortfolioState();
}

class _PortfolioState extends ConsumerState<PortfolioPanel> {
  PortfolioConfig? selectedPortfolio;

  final portfolioDetailsProvider = Provider.family<String, PortfolioConfig>((ref, portfolio) {
    // Use watch so this updates if the model manager or assets change
    final allAssets = ref.watch(useAssetsProvider);

    final symbols = allAssets
        .where((asset) => portfolio.metaIds.contains(asset.id))
        .map((asset) => asset.symbol)
        .join(', ');

    final weight = (portfolio.targetWeight * 100).toStringAsFixed(0);
    final balance = (portfolio.rebalanceThreshold * 100).toStringAsFixed(0);

    return "${portfolio.portfolioName}: [weight: $weight%], "
        "[balance: $balance%], "
        "[$symbols]";
  });


  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(loadDatabaseProvider);
    final usePortfolios = ref.watch(portfolioLoaderProvider);
    final portfolios = usePortfolios.whenData((portfolios) => portfolios).value ?? [];

    return Shrinkable(
      title: "Portfolios",
      body: dbAsync.when(
        data: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _addPortfolio(),
                for (var portfolio in portfolios)
                  _changePortfolio(portfolio),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Database Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _addPortfolio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text("New portfolio"),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            showPortfolio(context, selectedPortfolio, (newPortfolio) async {
              await ref.read(modelConfigProvider.notifier).save<PortfolioConfig>(PortfolioConfigSchema(), newPortfolio);
              ref.invalidate(portfolioLoaderProvider);
            });
          },
        )
      ],
    );
  }

  Widget _changePortfolio(PortfolioConfig portfolio) {
    final details = ref.watch(portfolioDetailsProvider(portfolio));

    // final allAssets = ref.watch(useAssetsProvider);
    //
    // final portfolioAssets = allAssets.where((a) => portfolio.metaIds.contains(a.id));
    // final symbols = portfolioAssets.map((a) => a.symbol).join(', ');
    //
    // final weight = (portfolio.targetWeight * 100).toStringAsFixed(0);
    // final balance = (portfolio.rebalanceThreshold * 100).toStringAsFixed(0);
    //
    // final details = "${portfolio.portfolioName}: [weight: $weight%], "
    //     "[balance: $balance%], "
    //     "[${symbols.isEmpty ? 'Loading symbols...' : symbols}]";

    return Shrinkable(
      title: portfolio.portfolioName,
      actions: [
        IconButton(
          icon: const Icon(Icons.update_outlined),
          onPressed: () {
            showPortfolio(context, portfolio, (newPortfolio) async {
              await ref.read(modelConfigProvider.notifier).update<PortfolioConfig>(PortfolioConfigSchema(), newPortfolio);
              ref.invalidate(portfolioLoaderProvider);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.remove_outlined),
          onPressed: () async {
            await ref.read(modelConfigProvider.notifier).delete<PortfolioConfig>(PortfolioConfigSchema(), portfolio);
            ref.invalidate(portfolioLoaderProvider);
          },
        ),
      ],
      expanded: true,
      body: Text(details, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
