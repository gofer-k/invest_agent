import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/period_type.dart';
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

class StrategyDialog extends ConsumerStatefulWidget {
  final Function(Strategy? strategy) onSave;
  final Strategy? strategy;
  const StrategyDialog({super.key, required this.onSave, required this.strategy});

  @override
  ConsumerState<StrategyDialog> createState() => _StrategyDialogState();
}

class _StrategyDialogState extends ConsumerState<StrategyDialog> {
  late final TextEditingController controllerName;
  late final TextEditingController controllerBudget;
  bool addingParameter = false;
  late StrategyType _selectedType = widget.strategy?.type ?? StrategyType.empty;
  late PeriodType _selectedPeriod = Strategy.defaultPeriod;
  FiatCurrencyEnum _selectedCurrency = Strategy.defaultCurrency;
  late final double _budget = widget.strategy?.cash ?? Strategy.defaultBudget;
  late DateTime _beginDate;
  late DateTime _endDate;
  bool _isDateRange = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedType = widget.strategy?.type ?? StrategyType.empty;
    _selectedPeriod = widget.strategy?.analysisPeriod ?? Strategy.defaultPeriod;

    final firstAllowedDate = DateTime(2000);

    // Ensure initial dates are not before firstDate (2000) to avoid picker assertion errors
    DateTime begin = widget.strategy?.beginDate ?? firstAllowedDate;
    _beginDate = begin;

    DateTime end = widget.strategy?.endDate ?? _beginDate.subtract(const Duration(days: yearDays));
    if (end.isBefore(firstAllowedDate)) end = firstAllowedDate;
    _endDate = end;

    _isDateRange = widget.strategy?.endDate != null;
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
              _strategyContents(_selectedType)

            ],
          )
        ),
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            final name = controllerName.text.trim();
            if (name.isEmpty ||  _selectedType == StrategyType.empty) return;

            final newStrategy = Strategy(
              id: widget.strategy?.id ?? Strategy.defaultId,
              name: name,
              cash: double.tryParse(controllerBudget.text) ?? _budget,
              currency: _selectedCurrency.data,
              analysisPeriod: _selectedPeriod,
              type: _selectedType,
              beginDate: _beginDate,
              endDate: _isDateRange ? _endDate : calculateEndDate(_beginDate, _selectedPeriod));
            widget.onSave(newStrategy);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        )
      ]
    );
  }

  Widget _selectStrategy() {
    return Dropdown<StrategyType>(
      onSelected: (StrategyType newType) {
        setState(() => _selectedType = newType);
      },
      choices:StrategyType.values,
      choiceType: _selectedType,
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
                onSelected: (FiatCurrencyEnum c) => setState(() => _selectedCurrency = c),
                choiceType: _selectedCurrency,
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
                    initialDate: _beginDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _beginDate = date);
                },
                child: Text("Start: ${_beginDate.toIso8601String().split('T')[0]}"),
              ),
             const SizedBox(width: 6),
             if (_isDateRange)
               OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: _beginDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                  child: Text("End: ${_endDate.toIso8601String().split('T')[0]}"),
                ),
            if (!_isDateRange)
              Expanded(flex: 1,
                child: DropdownButtonFormField<PeriodType>(
                  decoration: const InputDecoration(labelText: "Period analysis"),
                  initialValue: _selectedPeriod,
                  items: PeriodType.values.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))
                  ).toList(),
                  onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedPeriod = val);
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

  Widget _strategyContents(StrategyType type) {
    return switch (type) {
      StrategyType.meanReversion => throw UnimplementedError(),
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

  Widget _meanReversionStrategy() {
    return Column(
      children: [

      ]
    );
  }

  DateTime calculateEndDate(DateTime beginDate, PeriodType period) {
    if (period.days < 0) {
      return DateTime.now();
    }
    return beginDate.add(periodSpan(period) ?? Duration.zero);
  }
}
