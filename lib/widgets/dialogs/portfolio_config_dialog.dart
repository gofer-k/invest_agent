import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_config.dart';

import '../../model/analysis_period.dart';
import '../../model/indicator_schema.dart';
import '../../providers/indicator_provider.dart';
import '../../providers/load_database_provider.dart';
import '../../providers/model_config.dart';
import '../../utils/choice_chart_parameter.dart';
import '../utils/shrinkable.dart';

void showPortfolio(
  BuildContext context, PortfolioConfig? portfolio,
  Function(PortfolioConfig portfolio) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PortfolioDialog(portfolioConfig: portfolio, onSave: onSave);
    },
  );
}

class PortfolioDialog extends ConsumerStatefulWidget {
  final Function(PortfolioConfig newPortfolio) onSave;
  final PortfolioConfig? portfolioConfig;

  const PortfolioDialog({
    super.key, required this.onSave, required this.portfolioConfig});

  @override
  ConsumerState<PortfolioDialog> createState() => _PortfolioDialogState();
}

class _PortfolioDialogState extends ConsumerState<PortfolioDialog> {
  late final TextEditingController controller;

  // State variables
  final Map<AssetConfig, List<Indicator>> _config = {};
  AssetConfig? _selectedAsset;
  PeriodType  _selectedPeriod = PeriodType.fiveYears;
  Indicator _selectedIndicator = Indicator.emptyIndicator();
  List<Indicator> _indicators = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.portfolioConfig?.portfolioName ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadState();
    });
  }

  Future<void> _loadState() async {
    if (widget.portfolioConfig != null) {
      // final metaIdsSet = widget.portfolioConfig!.metaIds.toSet();
    }

    _indicators = await ref.read(indicatorProvider(CacheKeyType.analysisCache, true)).getItems();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsLoaderProvider);

    return assetsAsync.when(
      data: (assets) {
        assets.sort((left, right) => left.symbol.compareTo(right.symbol));
        assets.add(AssetConfig.defaultAsset());
        if (assets.isNotEmpty) {
          _selectedAsset = assets.first;
        }
        return _buildMainContents(assets);
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Failed to load assets data: $error',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        );
      },
      loading: () =>
         const AlertDialog(
           content: SizedBox(height: 100,
             child: Center(child: CircularProgressIndicator()))),
    );
  }

  Widget _buildMainContents(List<AssetConfig> assets) {
    final titleStr = widget.portfolioConfig == null ? "Add Portfolio" : "Update Portfolio";
    return AlertDialog(
      title: Text(titleStr),
      content: SingleChildScrollView( // Added to prevent overflow on small screens
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Portfolio Name",
                hintText: "Enter portfolio name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Center(child:
            _buildPeriodSelector(),
            // ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AssetConfig>(
                    initialValue: _selectedAsset,
                    hint: const Text("Select asset"),
                    items: assets.map((asset) => DropdownMenuItem(
                      value: asset,
                      child: Text(asset.symbol),
                    )).toList(),
                    onChanged: (AssetConfig? newValue) {
                      if (newValue != null) {
                        _selectedAsset = newValue;
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () {
                   setState(() => _handleAddNewAsset(_selectedAsset) );
                  }
                ),
              ],
            ),
            ..._config.entries.map((entry) {
                return Shrinkable(title: entry.key.toDetailString(),
                  body: Column(
                    children: [
                      Center(child: Row(
                        children: [
                          _buildIndicatorSelector(),
                          IconButton(
                            icon: const Icon(Icons.add_box_outlined),
                            onPressed: () {
                              // setState(() => _handleAddNewAsset(_selectedAsset) );
                            }
                          ),
                        ])
                      ),
                    ]
                  )
                );
              }
            ),
            // if (config.isNotEmpty) ...[
              // const SizedBox(height: 8),
              // Wrap(
              //   spacing: 8,
              //   children: config.map((asset) => Chip(
              //     label: Text(asset.symbol),
              //     onDeleted: () => setState(() => config.remove(asset)),
              //   )).toList(),
              // ),
            // ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _savePortfolio,
          child: const Text("Save"),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return choiceChartParameter<PeriodType>(
        Theme.of(context).textTheme.labelMedium,
        Colors.transparent,
        _selectedPeriod,
        PeriodType.values,
        (PeriodType period) {
          setState(() => _selectedPeriod = period );
        }
    );
  }

  Widget _buildIndicatorSelector() {
    return choiceChartParameter<Indicator>(
      Theme.of(context).textTheme.labelMedium,
      Colors.transparent,
      _selectedIndicator,
      _indicators,
      (Indicator indicator) {
        setState(() => _selectedIndicator = indicator );
      }
    );
  }

  void _savePortfolio() {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final newPortfolio = PortfolioConfig(
      id: widget.portfolioConfig?.id,
      portfolioName: name,
      assetIndicators: _config,
      periodType: PeriodType.fiveYears,
      targetWeight: 0.0,
      rebalanceThreshold: 0.0,
      metaIds: [],
    );

    widget.onSave(newPortfolio);
    Navigator.of(context).pop();
  }

  void _handleAddNewAsset(AssetConfig? selectedAsset) {
        _config.putIfAbsent(selectedAsset!, () => []);
  }
}
