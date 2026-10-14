import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/portfolio_provider.dart';
import '../providers/model_config.dart';
import '../model/portfolio_schema.dart';
import '../providers/load_database_provider.dart';
import '../widgets/dialogs/portfolio_config_dialog.dart';
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
    // final allAssets = ref.watch(sortedAssetsProvider);
    // TODO: implement this
    return "";
  });


  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioLoaderProvider);
    final portfolios = portfolioAsync.whenData((portfolios) => portfolios).value ?? [];

    return Shrinkable(
      title: "Portfolios",
      body: Column(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: () => _openPortfolioDialog(context),
            label: const Text('Add portfolio'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: portfolios.length,
            itemBuilder: (BuildContext context, int index) {
              final portfolio = portfolios[index];
              return Card(child: ListTile(
                title: Text(portfolio.portfolioName),
                subtitle: Text(portfolio.portfolioDesc, style: const TextStyle(fontSize: 11)),
                trailing: _buildTrailingActions(context, portfolio)
                ));
            }),
        ]
      ),
    );
  }

  Future<void> _openPortfolioDialog(BuildContext context, {PortfolioConfig? portfolio}) async {
    final result = await showDialog<PortfolioConfig>(
        context: context,
        builder: (context) => PortfolioDialog(portfolioConfig: portfolio));
    if (result != null) {
      final notifier = ref.read(portfolioProvider(CacheKeyType.analysisCache).notifier);
      if (portfolio == null) {
        notifier.addEntry(result);
      } else {
        notifier.updateEntry(result);
      }
    }
  }

  Widget? _buildTrailingActions(BuildContext context, PortfolioConfig portfolio) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _openPortfolioDialog(context, portfolio: portfolio),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () => _handleDelete(ref, portfolio),
        ),
      ]
    );
  }

  void _handleDelete(WidgetRef ref, PortfolioConfig portfolio) {
    if (!portfolio.isEmpty()) {
      ref.read(portfolioProvider(CacheKeyType.analysisCache).notifier)
          .deleteEntry(portfolio);
    }
  }
}
