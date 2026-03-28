import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/model_manager.dart';
import '../model/portfolio_config.dart';
import '../providers.dart';
import '../widgets/portfolio_config_dialog.dart';
import '../widgets/utils/shrinkable.dart';

class PortfolioPanel extends ConsumerStatefulWidget {
  const PortfolioPanel({super.key});

  @override
  ConsumerState<PortfolioPanel> createState() => _PortfolioState();
}

class _PortfolioState extends ConsumerState<PortfolioPanel> {
  PortfolioConfig? selectedPortfolio;

  @override
  Widget build(BuildContext context) {
    final dbAsync = ref.watch(databaseHelperProvider);
    // final portfolios = ref.watch(usePortfolios);
    final portfolios = ref.watch(modelManagerProvider.select(
            (s) => s.getItems<PortfolioConfig>()));

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
              await ref.read(modelManagerProvider.notifier).save<PortfolioConfig>(PortfolioConfigSchema(), newPortfolio);
            });
          },
        )
      ],
    );
  }

  Widget _changePortfolio(PortfolioConfig portfolio) {
    return Shrinkable(
      title: portfolio.portfolioName,
      actions: [
        IconButton(
          icon: const Icon(Icons.update_outlined),
          onPressed: () {
            showPortfolio(context, portfolio, (newPortfolio) async {
              await ref.read(modelManagerProvider.notifier).update<PortfolioConfig>(PortfolioConfigSchema(), newPortfolio);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.remove_outlined),
          onPressed: () async {
            await ref.read(modelManagerProvider.notifier).delete<PortfolioConfig>(PortfolioConfigSchema(), portfolio);
          },
        ),
      ],
      expanded: true,
      body: Column(
        children: [
          Text(portfolio.portfolioName, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
