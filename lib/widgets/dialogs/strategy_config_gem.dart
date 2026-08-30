import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/results/strategies/strategy_schema.dart';
import '../../providers/model_config.dart';
import '../../providers/strategy_session.dart';

class StrategyConfigGem extends ConsumerWidget {
  final Strategy? strategyKey;
  const StrategyConfigGem({super.key, required this.strategyKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(strategySessionProvider(strategyKey));
    final notifier = ref.read(strategySessionProvider(strategyKey).notifier);
    final assets = ref.watch(sortedAssetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

      ]);
  }

}