import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/asset_config.dart';
import '../../model/results/strategies/global_equity_momentum.dart';
import '../../model/results/strategies/strategy_schema.dart';
import '../../providers/model_config.dart';
import '../../providers/strategy_session.dart';
import '../utils/dropdownlist.dart';

class StrategyConfigGem extends ConsumerWidget {
  final Strategy? strategyKey;

  const StrategyConfigGem({super.key, required this.strategyKey});

  static const List<String> mainRegions = [
    "USA",
    "Emerging market",
    "Asia",
    "USA",
    "South America"
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(
        strategySessionProvider(strategyKey)) as GemStrategyConfig;
    final notifier = ref.read(strategySessionProvider(strategyKey).notifier);
    final assets = ref.watch(sortedAssetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Container(padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
            color: Theme.of(context).colorScheme.inverseSurface, width: 1)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Main asset"),
              const SizedBox(width: 8),
              Flexible(flex: 2,
                child: DropdownList<AssetConfig>(
                onSelected: (AssetConfig asset) =>
                notifier.save(currentStrategy.copyWith(
                newMainAsset: currentStrategy.mainAsset
                    .copyWith(newAsset: asset))),
                choiceType: currentStrategy.mainAsset.asset,
                choices: assets,
                backgroundColor: Colors.transparent)
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
          border: Border.all(
          color: Theme.of(context).colorScheme.inverseSurface, width: 1)),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Supplement assets"),
                  const SizedBox(width: 8),
                  Flexible(flex: 2,
                    child: DropdownList<AssetConfig>(
                      onSelected: (AssetConfig asset) {
                        if (!currentStrategy.mainAsset.supportingAssets
                          .contains(asset)) {
                          notifier.save(currentStrategy.copyWith(
                            newMainAsset: currentStrategy.mainAsset.copyWith(
                              newSupportingAssets: {...currentStrategy.mainAsset.supportingAssets, asset})
                          ));
                        }
                      },
                    choiceType:
                      currentStrategy.mainAsset.supportingAssets.isNotEmpty
                        ? currentStrategy.mainAsset.supportingAssets.first
                        : AssetConfig.defaultAsset(),
                    choices: assets,
                    backgroundColor: Colors.transparent)
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8,
                children: currentStrategy.mainAsset.supportingAssets.map((
                  asset) => Chip(
                    label: Text(asset.symbol),
                    onDeleted: () {
                      notifier.save(currentStrategy.copyWith(
                        newMainAsset: currentStrategy.mainAsset.copyWith(
                          newSupportingAssets: currentStrategy.mainAsset
                            .supportingAssets.where((a) => a != asset).toSet())
                      ));
                    })).toList(),
              ),
            ],
          ),
        ),
    ]);
  }
}
