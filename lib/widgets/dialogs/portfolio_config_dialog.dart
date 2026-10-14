import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/providers/portfolio_session.dart';

import '../../model/period_type.dart';

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
  bool _isDateRange = false;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.portfolioConfig?.portfolioName ?? '');
    controllerName = TextEditingController(text: widget.portfolioConfig?.portfolioDesc ?? '');
    controllerName = TextEditingController(text: widget.portfolioConfig?.riskFreeRatePerYear.toString() ?? '');
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDesc.dispose();
    controllerRiskFreeRate.dispose();
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
                _selectAssetAllocations(currentPortfolio, notifier),
                const SizedBox(height: 8),
                _selectStrategy(currentPortfolio, notifier),
              ],
            )
          ),
        ),
    );
  }

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
        Expanded(flex: 2,
          child: TextField(
            controller: controllerRiskFreeRate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Risk free rate'),
          ),
        ),
        const SizedBox(height: 8),
        _selectPeriod(currentPortfolio, notifier),
      ]
    );
  }

  Widget _selectPeriod(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: notifier.startDateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
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
                firstDate: notifier.startDateTime ?? DateTime(2000),
                lastDate: DateTime(2100),
              );
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
      ],
    );
  }

  Widget _selectAssetAllocations(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Container();
  }

  Widget _selectStrategy(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Container();
  }
}
