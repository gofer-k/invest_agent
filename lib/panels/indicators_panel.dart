import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/widgets/utils/shrinkable.dart';

import '../providers/indicator_provider.dart';
import '../providers/load_database_provider.dart';
import '../widgets/dialogs/indicator_config_dialog.dart';

class IndicatorsPanel extends ConsumerStatefulWidget {
  const IndicatorsPanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndicatorsPanelState();
}

class _IndicatorsPanelState extends ConsumerState<IndicatorsPanel> {
  @override
  Widget build(BuildContext context) {
    final indicatorsPController = ref.watch(indicatorProvider(CacheKeyType.analysisCache, true));
    final indicators = indicatorsPController.getItems();

    return Shrinkable(title: "Indicators",
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _handleAddIndicator(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add indicator'),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: indicators.length,
            itemBuilder: (BuildContext context, int index) {
              final indicator = indicators[index];
              return Card(child: ListTile(
                  title: Text(indicator.name),
                  subtitle: Text(indicator.type.name, style: const TextStyle(fontSize: 11)),
                  trailing: _buildTrailingActions(context, indicator)
                ),
              );
          })
        ]
      ));
  }

  void _handleAddIndicator(BuildContext context, WidgetRef ref) {
    showIndicator(context, null, (newIndicator) {
      if (newIndicator != null) {
        ref.read(indicatorProvider(CacheKeyType.analysisCache, true).notifier).addEntry(newIndicator);
      }
    });
  }

  Widget _buildTrailingActions(BuildContext context, Indicator indicator) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: (){
            showIndicator(context, indicator, (newIndicator) {
              if (newIndicator != null) {
                ref.read(indicatorProvider(CacheKeyType.analysisCache, true).notifier).updateIndicator(newIndicator);
              }
            });
        }),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () => _handleDelete(context, ref, indicator)
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, Indicator indicator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete an indicator data for ${indicator.toString()}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(indicatorProvider(CacheKeyType.analysisCache, true).notifier).deleteEntry(indicator);
    }
  }
}