import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/dialogs/strategy_config_mean_reversion.dart';

import '../../model/period_type.dart';
import '../../model/results/strategies/mean_reversion.dart';
import '../../model/results/strategies/strategy_schema.dart';
import '../../utils/chart_utils.dart';
import '../utils/dropdown.dart';
import 'asset_dialog.dart';

void showStrategy(BuildContext context, Strategy? strategy, Function(Strategy? strategy) onSave) {
  showDialog(context: context,
    builder: (BuildContext context) {
      return StrategyDialog(strategy: strategy, onSave: onSave);
    }
  );
}

class StrategyDialog extends StatefulWidget {
  final Function(Strategy? strategy) onSave;
  final Strategy? strategy;
  const StrategyDialog({super.key, required this.onSave, required this.strategy});

  @override
  StrategyDialogState createState() => StrategyDialogState();
}

class StrategyDialogState extends State<StrategyDialog> {
  late final TextEditingController controllerName;
  late final TextEditingController controllerBudget;
  bool addingParameter = false;
  late final double _budget = widget.strategy?.cash ?? Strategy.defaultBudget;
  bool _isDateRange = false;
  late Strategy _strategy = widget.strategy ?? Strategy.emptyStrategy();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDateRange = _strategy.isEmpty();
  }

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text:  widget.strategy?.name ?? '');
    controllerBudget = TextEditingController(text:  _budget.toString());
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerBudget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text("Strategy: ${widget.strategy?.name ?? 'New'}"),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _generalStrategyContents(),
              _selectStrategy(),
              const SizedBox(height: 8),
              _strategyContents(_strategy.type)
            ],
          )
        ),
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            final name = controllerName.text.trim();
            if (name.isEmpty ||  _strategy.type == StrategyType.empty) return;

            final newStrategy = Strategy(
              id: _strategy.id,
              name: name,
              cash: double.tryParse(controllerBudget.text) ?? _budget,
              currency: _strategy.currency,
              analysisPeriod: _strategy.analysisPeriod,
              type: _strategy.type,
              beginDate: _strategy.beginDate,
              endDate: _isDateRange ? _strategy.endDate : calculateEndDate(_strategy.beginDate, _strategy.analysisPeriod));
            widget.onSave(newStrategy);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        )
      ]
    );
  }

  Widget _generalStrategyContents() {
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
                onSelected: (FiatCurrencyEnum c) => setState(() => _strategy = _strategy.copyWith(newCurrency: c)),
                choiceType: _strategy.currency,
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
                    initialDate: _strategy.beginDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _strategy = _strategy.copyWith(newBeginDate: date));
                },
                child: Text("Start: ${_strategy.beginDate.toIso8601String().split('T')[0]}"),
              ),
             const SizedBox(width: 6),
             if (_isDateRange)
               OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _strategy.endDate,
                      firstDate: _strategy.beginDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _strategy.copyWith(newEndDate: date));
                  },
                  child: Text("End: ${_strategy.endDate.toIso8601String().split('T')[0]}"),
                ),
            if (!_isDateRange)
              Expanded(flex: 1,
                child: DropdownButtonFormField<PeriodType>(
                  decoration: const InputDecoration(labelText: "Period analysis"),
                  initialValue: _strategy.analysisPeriod,
                  items: PeriodType.values.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))
                  ).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _strategy = _strategy.copyWith(newAnalysisPeriod: val));
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

  Widget _selectStrategy() {
    return Dropdown<StrategyType>(
      onSelected: (StrategyType newType) {
        setState(() => _strategy = _strategy.copyWith(newType: newType));
      },
      choices:StrategyType.values,
      choiceType: _strategy.type,
    );
  }

  Widget _strategyContents(StrategyType type) {
    return switch (type) {
      StrategyType.meanReversion => StrategyConfigMeanReversion(
        strategyConfig: (widget.strategy != null)
            ? widget.strategy as MeanReversionConfig
            : MeanReversionConfig.emptyStrategy(),
        onSave: (MeanReversionConfig strategyConfig) {
          setState(() => _strategy = strategyConfig);
        }),
      _ => Text("No implemented more strategies"),
      // StrategyType.momentum => throw UnimplementedError(),
      // StrategyType.arbitrary => throw UnimplementedError(),
      // StrategyType.asset => throw UnimplementedError(),
      // StrategyType.gem => throw UnimplementedError(),
      // StrategyType.indexFundRebalancing => throw UnimplementedError(),
      // StrategyType.trendFollowing => throw UnimplementedError(),
      // StrategyType.empty => throw UnimplementedError(),
    };
  }

  DateTime calculateEndDate(DateTime beginDate, PeriodType period) {
    if (period.days < 0) {
      return DateTime.now();
    }
    return beginDate.add(periodSpan(period) ?? Duration.zero);
  }
}
