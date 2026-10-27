import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/model/results/strategies/strategy_schema.dart';
import 'package:invest_agent/providers/portfolio_session.dart';
import 'package:invest_agent/providers/strategy_provider.dart';
import 'package:invest_agent/widgets/dialogs/strategy_dialog.dart';
import 'package:money2/money2.dart';

import '../../model/period_type.dart';
import '../../providers/load_database_provider.dart';
import '../utils/dropdownlist.dart';

extension CurrencyExtension on Currency {
  /// Returns a custom string for UI display, e.g., "PLN (zł)"
  String get display => isoCode;
}

void showPortfolio(
  BuildContext context, PortfolioConfig? portfolio,
  Function(PortfolioConfig? portfolio) onSave) async {
  final result = await showDialog<PortfolioConfig>(
    context: context,
    builder: (context) => PortfolioDialog(portfolioConfig: portfolio),
  );
  onSave(result);
}

class PortfolioDialog extends ConsumerStatefulWidget {
  final PortfolioConfig? portfolioConfig;

  const PortfolioDialog({super.key, required this.portfolioConfig});

  @override
  ConsumerState<PortfolioDialog> createState() => _PortfolioDialogState();
}

class _PortfolioDialogState extends ConsumerState<PortfolioDialog> {
  late final TextEditingController controllerName;
  late final TextEditingController controllerDesc;
  late final TextEditingController controllerRiskFreeRate;
  late final TextEditingController controllerCapital;

  bool _isDateRange = false;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.portfolioConfig?.portfolioName ?? '');
    controllerDesc = TextEditingController(text: widget.portfolioConfig?.portfolioDesc ?? '');
    controllerRiskFreeRate = TextEditingController(text: widget.portfolioConfig?.riskFreeRatePerYear.toString() ?? '');
    controllerCapital = TextEditingController(
      text: widget.portfolioConfig?.initialCapital.toDouble().toString() ?? PortfolioConfig.defaultCapital.toDouble().toString());
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDesc.dispose();
    controllerRiskFreeRate.dispose();
    controllerCapital.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPortfolio = ref.watch(portfolioSessionProvider(widget.portfolioConfig));
    final notifier = ref.read(portfolioSessionProvider(widget.portfolioConfig).notifier);
    return AlertDialog.adaptive(
      title: Text("Portfolio: ${currentPortfolio.portfolioName}"),
      content: SizedBox(width: 320,
        child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainContents(currentPortfolio, notifier),
                const SizedBox(height: 8),
                _selectStrategy(currentPortfolio, notifier),
              ],
            )
          ),
        ),
        actions: [
          BackButton(onPressed: () => Navigator.of(context).pop()),
          ElevatedButton(
            onPressed: () {
              final name = controllerName.text.trim();
              final capital = double.tryParse(controllerCapital.text) ?? PortfolioConfig.defaultCapital.amount.toDecimal().toDouble();
              final riskFreeRate = double.tryParse(controllerRiskFreeRate.text) ?? PortfolioConfig.defaultRiskFreeRate;

              if (name.isEmpty || capital < 0.0) return;

              notifier.updateField((s) => s.copyWith(
                newName: name, newDesc: controllerDesc.text,
                newInitialCapital: Money.fromNum(capital, isoCode: currentPortfolio.initialCapital.currency.isoCode),
                newRiskFreeRatePerYear: riskFreeRate));

              final finalizedPortfolio = ref.read(portfolioSessionProvider(widget.portfolioConfig));
              Navigator.of(context).pop(finalizedPortfolio);
            },
            child: const Text("Save"),
          )
        ]
    );
  }

  // -- General contents
  Widget _buildMainContents(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controllerName,
          decoration: const InputDecoration(labelText: 'Portfolio Name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controllerDesc,
          decoration: const InputDecoration(labelText: 'Portfolio Description'),
        ),
        const SizedBox(height: 8),
        _capitalContents(currentPortfolio, notifier),
        const SizedBox(height: 8),
        TextField(
          controller: controllerRiskFreeRate,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          decoration: const InputDecoration(labelText: 'Risk free rate'),
        ),
        const SizedBox(height: 8),
        _analysisPeriod(currentPortfolio, notifier),
      ]
    );
  }

  Widget _capitalContents(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    final currencies = CommonCurrencies().asList();
    return Row(
      children: [
        Expanded(flex: 2,
          child: TextField(
            controller: controllerCapital,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Initial Capital'),
          ),
        ),
        const SizedBox(width: 8),
        DropdownList<Currency>(
          onSelected: (Currency c) => notifier.updateField(
            (portfolio) => portfolio.copyWith(
                newInitialCapital: Money.fromNum(
                  currentPortfolio.initialCapital.amount.toDecimal().toDouble(),
                  isoCode: c.isoCode))),
          choiceType: currentPortfolio.initialCapital.currency,
          choices: currencies,
          iconBuilder: (Currency c) => Text(c.display),
          backgroundColor: Colors.transparent,
        )
      ]
    );
  }

  Widget _selectPeriodType() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _analysisPeriod(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    final firstDate= DateTime(2000);
    final lastDate = DateTime(2100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _selectPeriodType(),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: notifier.startDateTime,
                  firstDate: firstDate,
                  lastDate: lastDate);
                if (date != null) {
                  notifier.updateField((portfolio) => portfolio.copyWith(newStartDateTime: date));
                }
              },
              child: Text("Start: ${notifier.startDateTime?.toIso8601String().split('T')[0]}"),
            ),
            const SizedBox(width: 6),
            if (_isDateRange)
              OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: notifier.endDateTime ?? DateTime.now(),
                    firstDate: notifier.startDateTime ?? firstDate,
                    lastDate: lastDate);
                  if (date != null) {
                    notifier.updateField((portfolio) => portfolio.copyWith(newEndDateTime: date));
                  }
                },
                child: Text("End: ${notifier.endDateTime?.toIso8601String().split('T')[0]}"),
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
                    notifier.updateField((portfolio) => portfolio.copyWith(newAnalysisPeriod: val));
                  }
                ),
              ),
          ])
        ]
    );
  }
  // -- General contents - END

  Widget _selectStrategy(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notifier.strategy == null)
          ElevatedButton.icon(
            onPressed: () => _openStrategyDialog(context, notifier),
            icon: const Icon(Icons.add),
            label: const Text('Add strategy'),
          ),
        if (notifier.strategy != null)
          Card(child: ListTile(
            title: Text(notifier.strategy!.name),
            subtitle: _viewStrategyContents(context, notifier.strategy!),
            trailing: _buildTrailingStrategyActions(context, notifier, notifier.strategy!),
          ))
      ],
    );
  }

  Future<void> _openStrategyDialog(BuildContext context, PortfolioSession notifier) async {
    final result = await showDialog<Strategy>(
      context: context,
      builder: (context) => StrategyDialog(strategy: notifier.strategy),
    );

    if (result != null) {
      notifier.updateField((portfolio) => portfolio.copyWith(newStrategy: result));
    }
  }

  Widget? _buildTrailingStrategyActions(BuildContext context,
      PortfolioSession notifier, Strategy strategy) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => showStrategy(context, strategy, (updatedStrategy) {
            if (updatedStrategy != null) {
              ref.read(strategyProvider(CacheKeyType.analysisCache).notifier)
                 .addEntry(updatedStrategy);
              notifier.updateField((portfolio) => portfolio.copyWith(
                  newStrategy: updatedStrategy));
            }
          })
        )
      ]
    );
  }

  Widget _viewStrategyContents(BuildContext context, Strategy strategy) {
    final assets = strategy.getAssetAllocations();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strategy.type.name, style: Theme.of(context).textTheme.labelLarge),
          const Divider(),
          ...assets.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(child: Text(item.asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text("${item.targetWeight}%"),
                const SizedBox(width: 16),
                Text("Shares: ${item.assetSharesCount}"),
              ],
            ),
          )),
        ]
    );
  }
}
