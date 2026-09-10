import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';

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
    "South America"
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(strategySessionProvider(strategyKey)) as GemStrategyConfig;
    final notifier = ref.read(strategySessionProvider(strategyKey).notifier);
    final assets = ref.watch(sortedAssetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _buildAssetsSection(context, currentStrategy, notifier, assets),
        const SizedBox(height: 8),
        _buildMomentumSection(context, currentStrategy, notifier)
      ],
    );
  }

  Widget _buildAssetsSection(
      BuildContext context,
      GemStrategyConfig currentStrategy,
      StrategySession notifier,
      List<AssetConfig> assets,) {
    return Shrinkable(title: "Assets",
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.inverseSurface,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text("Equites"),
                const SizedBox(height: 8),
                _buildMainAssetSection(context, currentStrategy, notifier, assets, true),
                const SizedBox(height: 8),
                _buildSupportingAssetsSection(context, currentStrategy, notifier, assets, true)
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.inverseSurface,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text("Momentum assets (Bonds, cash)"),
                const SizedBox(height: 8),
                _buildMainAssetSection(context, currentStrategy, notifier, assets, false),
                const SizedBox(height: 8),
                _buildSupportingAssetsSection(context, currentStrategy, notifier, assets, false)
              ],
            ),
          ),
        ]
      )
    );
  }

  Widget _buildMainAssetSection(
    BuildContext context,
    GemStrategyConfig currentStrategy,
    StrategySession notifier,
    List<AssetConfig> assets,
    bool riskyMode
  ) {
    final title = riskyMode ? "Main asset" : "Momentum asset";
    final targetGroup = riskyMode ? currentStrategy.mainAsset : currentStrategy.momentumAsset;

    void updateGroup(dynamic newGroup) {
      notifier.save(currentStrategy.copyWith(
      newMainAsset: riskyMode ? newGroup : null,
      newMomentumAsset: riskyMode ? null : newGroup));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: DropdownList<AssetConfig>(
            onSelected: (AssetConfig asset) =>
              updateGroup(targetGroup.copyWith(newAsset: asset)),
            choiceType: targetGroup.asset,
            choices: assets,
            backgroundColor: Colors.transparent,
          ),
        )
      ],
    );
  }

  Widget _buildSupportingAssetsSection(
    BuildContext context,
    GemStrategyConfig currentStrategy,
    StrategySession notifier,
    List<AssetConfig> assets,
    bool riskyMode
  ) {
    final targetGroup = riskyMode ? currentStrategy.mainAsset : currentStrategy.momentumAsset;

    void updateGroup(dynamic newGroup) {
      notifier.save(currentStrategy.copyWith(
        newMainAsset: riskyMode ? newGroup : null,
        newMomentumAsset: riskyMode ? null : newGroup,
      ));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Supplement assets"),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: DropdownList<AssetConfig>(
                onSelected: (AssetConfig asset) {
                  if (!targetGroup.supportingAssets.contains(asset)) {
                    final updatedAssets = {...targetGroup.supportingAssets, asset};
                    updateGroup(targetGroup.copyWith(newSupportingAssets: updatedAssets));
                  }
                },
                choiceType: targetGroup.supportingAssets.isNotEmpty
                    ? targetGroup.supportingAssets.first
                    : AssetConfig.defaultAsset(),
                choices: assets,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: targetGroup.supportingAssets.map((asset) {
            return Chip(
              label: Text(asset.symbol),
              onDeleted: () {
                final deletedAssets = targetGroup.supportingAssets.where((a) => a != asset).toSet();
                updateGroup(targetGroup.copyWith(newSupportingAssets: deletedAssets));
              },
            );
          }).toList(),
        ),
      ]
    );
  }

  Widget _buildMomentumSection(
    BuildContext context,
    GemStrategyConfig currentStrategy,
    StrategySession notifier) {

    final rebalanceIntervalsInMonth = [2, 3, 6, 12, 18, 24];
    return Shrinkable(title: "Momentum parameters", body:
      Column(
       children: [
         // _buildEditingParameter(
         //     context,
         //     label: "Bonds 3m rate [%]",
         //     hint: GemStrategyConfig.defaultInflation.toStringAsFixed(2),
         //     currentParameter: currentStrategy.inflation,
         //     onCommit: (inflation) {
         //       notifier.save(currentStrategy.copyWith(newInflation: inflation));
         //     }),
         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Tooltip(
               message: """
Select moment window (in months) to how long looking in past 
to check out the current strategy's assets results against free risk rate.""",
               child: const Text("Absolut window [months]")),
             const SizedBox(width: 8),
             Flexible(
               flex: 2,
               child: DropdownList<int>(
                 onSelected: (int rebalanceInterval) {
                   notifier.save(currentStrategy.copyWith(newAbsoluteMomentumInMonth: rebalanceInterval));
                 },
                 choiceType: currentStrategy.absoluteMomentumInteval,
                 choices: rebalanceIntervalsInMonth,
                 backgroundColor: Colors.transparent,
               ),
             ),
           ],
         ),
         const SizedBox(width: 12),
         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Tooltip(
                 message: """
Select moment window (in months) to how long looking in past
to check out the strategy's main assets results against rebalancing assets ones.""",
                 child: const Text("Relative window [months]")),
             const SizedBox(width: 8),
             Flexible(
               flex: 2,
               child: DropdownList<int>(
                 onSelected: (int rebalanceInterval) {
                   notifier.save(currentStrategy.copyWith(newRelativeMomentumInMonth: rebalanceInterval));
                 },
                 choiceType: currentStrategy.relativeMomentumInterval,
                 choices: rebalanceIntervalsInMonth,
                 backgroundColor: Colors.transparent,
               ),
             ),
           ],
         ),
         const SizedBox(height: 12),
         _buildEditingParameter(
           context,
           label: "Free rate [%]",
           hint: GemStrategyConfig.defaultInflation.toStringAsFixed(2),
           currentParameter: currentStrategy.inflation,
           onCommit: (inflation) {
             notifier.save(currentStrategy.copyWith(newInflation: inflation));
         }),
       ]
      )
    );
  }

  Widget _buildEditingParameter(
    BuildContext context,
    { required String label, required double currentParameter, String? hint, Function(double newValue)? onCommit }) {

    return TextField(
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      controller: TextEditingController(text: currentParameter.toString()),
      onSubmitted: (value) {
        final inflation = double.tryParse(value);
        if (inflation != null) {
          onCommit!(inflation);
        }
      },
    );
  }
}
