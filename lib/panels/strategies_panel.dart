import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';

import '../model/results/strategies/strategy_schema.dart';
import '../providers/load_database_provider.dart';
import '../providers/strategy_provider.dart';
import '../widgets/dialogs/strategy_dialog.dart';

class StrategiesPanel extends ConsumerStatefulWidget{
  const StrategiesPanel({super.key});

  @override
  ConsumerState<StrategiesPanel> createState() => _StrategiesPanelState();
}

class _StrategiesPanelState extends ConsumerState<StrategiesPanel> {
  Strategy? selectedStrategy;

  @override
  Widget build(BuildContext context) {
    final strategies = ref.watch(strategyProvider(CacheKeyType.analysisCache)).getItems();
    return Shrinkable(title: "Strategies",
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _openStrategyDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add strategy'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: strategies.length,
            itemBuilder: (BuildContext context, int index) {
              final strategy = strategies[index];
              return Card(child: ListTile(
                  title: Text(strategy.name),
                  subtitle: Text(strategy.type.name, style: const TextStyle(fontSize: 11)),
                  trailing: _buildTrailingActions(context, strategy)
              ),
              );
            }
          ),
        ]
      )
    );
  }

  Widget? _buildTrailingActions(BuildContext context, Strategy strategy) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _openStrategyDialog(context, strategy: strategy),
          // {
          //   showStrategy(context, strategy, (newStrategy) {
          //     if (newStrategy != null && newStrategy != strategy) {
          //       ref.read(strategyProvider(CacheKeyType.analysisCache).notifier)
          //           .updateEntry(newStrategy);
          //     }
          //   });
          // },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () => _handleDelete(ref, strategy),
        ),
      ]
    );
  }

  void _handleDelete(WidgetRef ref, Strategy strategy) {
    if (!strategy.isEmpty()) {
      ref.read(strategyProvider(CacheKeyType.analysisCache).notifier)
          .deleteEntry(strategy);
    }
  }

  // Unified method for Add and Edit
  Future<void> _openStrategyDialog(BuildContext context, {Strategy? strategy}) async {
    final result = await showDialog<Strategy>(
      context: context,
      builder: (context) => StrategyDialog(strategy: strategy),
    );

    if (result != null) {
      final notifier = ref.read(strategyProvider(CacheKeyType.analysisCache).notifier);
      if (strategy == null) {
        notifier.addEntry(result);
      } else {
        notifier.updateEntry(result);
      }
    }
  }
}