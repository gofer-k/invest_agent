import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/widgets/asset_dialog.dart';
import 'package:invest_agent/widgets/utils/factor_slider.dart';

import '../providers/model_config.dart';

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
  late double targetWeight = widget.portfolioConfig?.targetWeight ?? 0.25;
  late double rebalanceThreshold = widget.portfolioConfig?.rebalanceThreshold ?? 0.05;
  List<AssetConfig> availableAssets = [];
  Set<AssetConfig> portfolioAssets = {};
  AssetConfig? selectedAsset;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.portfolioConfig?.portfolioName ?? '');
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final assets = await ref.read(assetsLoaderProvider.future);
      if (!mounted) return;

      setState(() {
        availableAssets = assets;
        availableAssets.sort((left, right) => left.symbol.compareTo(right.symbol));
        availableAssets.add(AssetConfig.defaultAsset());
        if (assets.isNotEmpty) {
          selectedAsset = assets.first;
        }

        if (widget.portfolioConfig != null) {
          final metaIdsSet = widget.portfolioConfig!.metaIds.toSet();
          portfolioAssets = assets.where((asset) => metaIdsSet.contains(asset.id)).toSet();

        }
        isLoading = false;
      });
    } catch (e) {
      // Handle error (e.g., show error message)
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AlertDialog(
        content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      );
    }

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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AssetConfig>(
                    initialValue: selectedAsset,
                    hint: const Text("Select asset"),
                    items: availableAssets.map((asset) => DropdownMenuItem(
                      value: asset,
                      child: Text(asset.symbol),
                    )).toList(),
                    onChanged: (AssetConfig? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedAsset = newValue;
                          portfolioAssets.add(newValue);
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () => _handleAddNewAsset(context),
                ),
              ],
            ),
            if (portfolioAssets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: portfolioAssets.map((asset) => Chip(
                  label: Text(asset.symbol),
                  onDeleted: () => setState(() => portfolioAssets.remove(asset)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 20),
            FactorSlider(
              label: 'Target weight (%)',
              initialValue: targetWeight,
              minValue: 0.0,
              maxValue: 1.0,
              onChanged: (val) => setState(() => targetWeight = val),
            ),
            FactorSlider(
              label: 'Rebalance threshold (%)',
              initialValue: rebalanceThreshold,
              minValue: 0.0,
              maxValue: 1.0,
              onChanged: (val) => setState(() => rebalanceThreshold = val),
            ),
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

  void _handleAddNewAsset(BuildContext context) {
    showAsset(context, selectedAsset, (newAsset) async {
      if (newAsset != null) {
        // Corrected Schema
        await ref.read(modelConfigProvider.notifier).save<AssetConfig>(
            AssetConfigSchema(), newAsset);

        setState(() {
          availableAssets.add(newAsset);
          portfolioAssets.add(newAsset);
          selectedAsset = newAsset;
        });
      }
    });
  }

  void _savePortfolio() {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final newPortfolio = PortfolioConfig(
      id: widget.portfolioConfig?.id,
      portfolioName: name,
      targetWeight: targetWeight,
      rebalanceThreshold: rebalanceThreshold,
      metaIds: portfolioAssets.map((a) => a.id).toList(),
    );

    widget.onSave(newPortfolio);
    Navigator.of(context).pop();
  }
}
