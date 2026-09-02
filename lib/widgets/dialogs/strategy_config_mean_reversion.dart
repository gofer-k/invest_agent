import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/providers/indicator_provider.dart';

import '../../model/indicator_schema.dart';
import '../../model/results/strategies/mean_reversion.dart';
import '../../model/results/strategies/strategy_schema.dart';
import '../../providers/model_config.dart';
import '../../providers/strategy_session.dart';
import '../utils/dropdownlist.dart';
import 'indicator_config_dialog.dart';

class StrategyConfigMeanReversion extends ConsumerWidget {
  final Strategy? strategyKey;

  const StrategyConfigMeanReversion({
    super.key,
    required this.strategyKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(strategySessionProvider(strategyKey)) as MeanReversionConfig;
    final notifier = ref.read(strategySessionProvider(strategyKey).notifier);

    final indicators = ref.watch(sortedIndicatorsProvider);
    final assets = ref.watch(sortedAssetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Asset" ),
            const SizedBox(width: 8),
            Flexible(flex: 2,
              child: DropdownList<AssetConfig>(
                onSelected: (AssetConfig asset) => notifier.save(currentStrategy.copyWith(newAsset: asset)),
                choiceType: currentStrategy.asset,
                choices: assets,
                backgroundColor: Colors.transparent)
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Indicator" ),
            const SizedBox(width: 8),
            Flexible(flex: 1,
              child: DropdownList<Indicator>(
                onSelected: (Indicator ind) => notifier.save(currentStrategy.copyWith(newIndicator: ind)),
                choiceType: currentStrategy.indicator,
                choices: indicators,
                backgroundColor: Colors.transparent,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: (){
                showIndicator(context, currentStrategy.indicator, (newIndicator) {
                  if (newIndicator != null) {
                    notifier.save(currentStrategy.copyWith(newIndicator: newIndicator));
                  }
                });
            }),
          ]
        )
      ]
    );
  }
}
