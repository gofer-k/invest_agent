import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/providers/indicator_provider.dart';

import '../../model/indicator_schema.dart';
import '../../model/results/strategies/mean_reversion.dart';
import '../../providers/model_config.dart';
import '../utils/dropdownlist.dart';
import 'indicator_config_dialog.dart';

class StrategyConfigMeanReversion extends ConsumerStatefulWidget {
  final MeanReversionConfig strategyConfig;
  final Function(MeanReversionConfig strategyConfig) onSave;
  const StrategyConfigMeanReversion({super.key, required this.strategyConfig, required this.onSave});

  @override
  ConsumerState<StrategyConfigMeanReversion> createState() => _StrategyConfigMeanReversionState();
}

class _StrategyConfigMeanReversionState extends ConsumerState<StrategyConfigMeanReversion> {
  late MeanReversionConfig config = widget.strategyConfig;

  @override
  void dispose() {
    widget.onSave(config);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                onSelected: (AssetConfig asset) => setState(() => config = config.copyWith(newAsset: asset)),
                choiceType: config.asset,
                choices: assets,
                backgroundColor: Colors.transparent)
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Indicator" ),
            const SizedBox(width: 8),
            Flexible(flex: 1,
              child: DropdownList<Indicator>(
                onSelected: (Indicator ind) => setState(() => config = config.copyWith(newIndicator: ind)),
                choiceType: config.indicator,
                choices: indicators,
                backgroundColor: Colors.transparent,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: (){
                showIndicator(context, config.indicator, (newIndicator) {
                  if (newIndicator != null) {
                    config = config.copyWith(newIndicator: newIndicator);
                  }
                });
            }),
          ]
        )
      ]
    );
  }
}