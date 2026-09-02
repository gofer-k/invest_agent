import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/strategy_session.dart';
import 'package:invest_agent/widgets/dialogs/strategy_config_gem.dart';
import 'package:invest_agent/widgets/dialogs/strategy_config_mean_reversion.dart';

import '../../model/period_type.dart';
import '../../model/results/strategies/strategy_schema.dart';
import '../../utils/chart_utils.dart';
import '../utils/dropdown.dart';
import 'asset_dialog.dart';

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
  late final TextEditingController controllerBudget;
  bool addingParameter = false;
  bool _isDateRange = false;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text:  widget.strategy?.name ?? '');
    controllerBudget = TextEditingController(text:  widget.strategy?.cash.toStringAsFixed(2) ?? Strategy.defaultBudget.toStringAsFixed(2));
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerBudget.dispose();
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
            final cash = double.tryParse(controllerBudget.text) ?? Strategy.defaultBudget;

            if (name.isEmpty || currentStrategy.type == StrategyType.empty) return;

            notifier.updateField((s) => s.copyWith(newName: name, newCash: cash));

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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 2,
              child: TextField(
                controller: controllerBudget,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Budget'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 1,
              child: Dropdown<FiatCurrencyEnum>(
                onSelected: (FiatCurrencyEnum c) => notifier.updateField(
                  (strategy) => strategy.copyWith(newCurrency: c)),
                choiceType: currentStrategy.currency,
                choices: FiatCurrencyEnum.values,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _selectAnalysisPeriod(),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: notifier.beginDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    notifier.updateField((strategy) => strategy.copyWith(newBeginDate: date));
                  }
                },
                child: Text("Start: ${notifier.beginDate.toIso8601String().split('T')[0]}"),
              ),
             const SizedBox(width: 6),
             if (_isDateRange)
               OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: notifier.endDate,
                      firstDate: notifier.beginDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      notifier.updateField((strategy) => strategy.copyWith(newEndDate: date));
                    }
                  },
                  child: Text("End: ${notifier.endDate.toIso8601String().split('T')[0]}"),
                ),
            if (!_isDateRange)
              Expanded(flex: 1,
                child: DropdownButtonFormField<PeriodType>(
                  decoration: const InputDecoration(labelText: "Period analysis"),
                  initialValue: notifier.analysisPeriod,
                  items: PeriodType.values.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))
                  ).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    notifier.updateField((strategy) => strategy.copyWith(newAnalysisPeriod: val));
                  }
                ),
              ),
          ],
        ),
      ]
    );
  }

  Widget _selectAnalysisPeriod() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Period", style: Theme.of(context).textTheme.labelLarge),
          Switch(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              value: _isDateRange,
              onChanged: (bool value) => setState(() => _isDateRange = value)),
          Text("Date range", style: Theme.of(context).textTheme.labelLarge),
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

  DateTime calculateEndDate(DateTime beginDate, PeriodType period) {
    if (period.days < 0) {
      return DateTime.now();
    }
    return beginDate.add(periodSpan(period) ?? Duration.zero);
  }
}
