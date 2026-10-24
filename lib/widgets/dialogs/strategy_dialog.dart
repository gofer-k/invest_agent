import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/strategy_session.dart';
import 'package:invest_agent/widgets/dialogs/strategy_config_gem.dart';
import 'package:invest_agent/widgets/dialogs/strategy_config_mean_reversion.dart';

import '../../model/results/strategies/strategy_schema.dart';
import '../utils/dropdown.dart';

Future<void> showStrategy(BuildContext context, Strategy? strategy,
    Function(Strategy? strategy) onSave) async {
  final result = await showDialog<Strategy>(
    context: context,
    builder: (context) => StrategyDialog(strategy: strategy),
  );
  onSave(result);
}

class StrategyDialog extends ConsumerStatefulWidget {
  final Strategy? strategy;

  const StrategyDialog({super.key, required this.strategy});

  @override
  ConsumerState<StrategyDialog> createState() => StrategyDialogState();
}
class StrategyDialogState extends ConsumerState<StrategyDialog> {
  late final TextEditingController controllerName;
  bool addingParameter = false;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text:  widget.strategy?.name ?? '');
  }

  @override
  void dispose() {
    controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStrategy = ref.watch(strategySessionProvider(widget.strategy));
    final notifier = ref.read(strategySessionProvider(widget.strategy).notifier);

    return AlertDialog.adaptive(
      title: Text("Strategy: ${currentStrategy.name}"),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _generalStrategyContents(
                currentStrategy,
                notifier),
              const SizedBox(height: 8),
              _selectStrategy(currentStrategy,
                notifier),
              const SizedBox(height: 8),
              _strategyContents(currentStrategy,
                notifier),
            ],
          )
        ),
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            final name = controllerName.text.trim();
            if (name.isEmpty || currentStrategy.type == StrategyType.empty) return;

            notifier.updateField((s) => s.copyWith(newName: name));

            final finalizedStrategy = ref.read(strategySessionProvider(widget.strategy));
            Navigator.of(context).pop(finalizedStrategy);
          },
          child: const Text("Save"),
        )
      ]
    );
  }

  Widget _generalStrategyContents(Strategy currentStrategy, StrategySession notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controllerName,
          decoration: const InputDecoration(labelText: 'Strategy Name'),
        ),
      ]
    );
  }

  Widget _selectStrategy(Strategy currentStrategy, StrategySession notifier) {
    return Dropdown<StrategyType>(
      onSelected: (StrategyType newType) {
        notifier.updateType(newType);
      },
      choices:StrategyType.values,
      choiceType: currentStrategy.type,
    );
  }

  Widget _strategyContents(Strategy currentStrategy, StrategySession notifier) {
    return switch (currentStrategy.type) {
      StrategyType.meanReversion => StrategyConfigMeanReversion(
          strategyKey: widget.strategy),
      StrategyType.gem => StrategyConfigGem(strategyKey: widget.strategy),
      _ => Text("No implemented more strategies"),
    };
  }
}
