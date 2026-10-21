import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/portfolio_schema.dart';
import 'package:invest_agent/providers/portfolio_session.dart';

import '../../model/asset_config.dart';
import '../../model/period_type.dart';
import '../../providers/model_config.dart';
import '../utils/dropdownlist.dart';

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
    controllerCapital = TextEditingController(text: widget.portfolioConfig?.initialCapital.toDouble().toString() ?? PortfolioConfig.defaultCapital.toDouble().toString());
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
        TextField(
          controller: controllerRiskFreeRate,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Risk free rate'),
        ),
        const SizedBox(height: 8),
        _analysisPeriod(currentPortfolio, notifier),
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

  Widget _selectAssetAllocations(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifier.assetAllocations.length,
      itemBuilder: (context, index) {
        final allocation = notifier.assetAllocations.elementAt(index);
        return _buildAssetAllocation(allocation, notifier);
      },
    );
  }

  Widget _buildAssetAllocation(AssetAllocation allocation, PortfolioSession notifier) {
    final assets = ref.watch(sortedAssetsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      leading: DropdownList<AssetConfig>(
        onSelected: (AssetConfig asset) {
          final currentAllocation = notifier.assetAllocations.firstWhereOrNull(
             (allocation) => allocation.asset == asset);
          if (currentAllocation == null) {
            notifier.assetAllocations.add(AssetAllocation.of(asset: asset));
          }
        },
        choiceType: allocation.asset,
        choices: assets,
        backgroundColor: Colors.transparent),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: allocation.targetWeight.toString()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target weight'),
            onChanged: (value) {
              if (value.isEmpty) return;
              final currentAllocation = allocation.copyWith(newTargetWeight: double.tryParse(value));
              notifier.assetAllocations.remove(allocation);
              notifier.assetAllocations.add(currentAllocation);
           }),
          const SizedBox(width: 8),
          TextField(
            controller: TextEditingController(text: allocation.assetSharesCount.toString()),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Shares count'),
            onChanged: (value) {
              if (value.isEmpty) return;
              final currentAllocation = allocation.copyWith(newAssetSharesCount: int.tryParse(value));
              notifier.assetAllocations.remove(allocation);
              notifier.assetAllocations.add(currentAllocation);
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete, color: colorScheme.error, size: 18),
            tooltip: 'Delete asset allocation',
            onPressed: () => notifier.assetAllocations.remove(allocation)
          ),
        ]
      )
    );
  }

  Widget _selectStrategy(PortfolioConfig currentPortfolio, PortfolioSession notifier) {
    return Container();
  }
}
