import 'package:flutter/material.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:invest_agent/widgets/trading_asset_dialog.dart';
import 'package:invest_agent/widgets/utils/dropdownlist.dart';
import 'package:invest_agent/widgets/utils/factor_slider.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

void showPortfolio(
  BuildContext context, PortfolioConfig? portfolio, DatabaseHelper db,
  Function(PortfolioConfig portfolio) onSave) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PortfolioDialog(portfolioConfig: portfolio, dbController: db,  onSave: onSave, db: db,);
    },
  );
}

class PortfolioDialog extends StatefulWidget {
  final Function(PortfolioConfig newPortfolio) onSave;
  final DatabaseHelper db;
  final PortfolioConfig? portfolioConfig;
  final DatabaseHelper dbController;

  const PortfolioDialog({
    super.key, required this.onSave, required this.portfolioConfig, required this.dbController, required this.db});

  @override
  State<PortfolioDialog> createState() => _PortfolioDialogState();
}

class _PortfolioDialogState extends State<PortfolioDialog> {
  late String portfolioName = widget.portfolioConfig?.portfolioName ?? '';
  late double targetWeight = widget.portfolioConfig?.targetWeight ?? 0.25;
  late double rebalanceThreshold = widget.portfolioConfig?.rebalanceThreshold ?? 0.05;
  List<AssetConfig> availableAssets = List.empty(growable: true);
  List<AssetConfig> portfolioAssets = List.empty(growable: true);
  final defaultAsset = AssetConfig(id: -1, symbol: "Not symbol", currency: FiatCurrency.usd(), stockExchange: StockExchange.lSe);
  late AssetConfig selectedAsset = defaultAsset;

  late final TextEditingController controller;

  Future<void> _loadState() async {
    final dbAssets = await widget.dbController.fetchAll<AssetConfig>(AssetConfigSchema());
    if (mounted) {
      setState(() {
        // Update UI after work is done
        availableAssets = dbAssets;
        if (availableAssets.isNotEmpty) {
          selectedAsset = availableAssets.first;
        } else {
          availableAssets = [defaultAsset];
          selectedAsset = defaultAsset;
        }
        if (widget.portfolioConfig != null) {
          portfolioAssets = availableAssets.where((asset) =>
              widget.portfolioConfig!.metaIds.contains(asset.id)).toList();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = portfolioName;
    _loadState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStr = widget.portfolioConfig == null ? "Add portfolio" : "Update portfolio";
    return AlertDialog(
      title: Text(titleStr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio name
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter portfolio name",
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textAlign: TextAlign.end,
          ),
          // Available assets
          Row(
            children: [
              Expanded(
                child: DropdownList<AssetConfig>(
                    hint: "Select asset",
                    choices: availableAssets,
                    choiceType: selectedAsset,
                    onSelected: (AssetConfig? selected) {
                      if (selected != null) {
                        setState(() => selectedAsset = selected);
                      }
                    }
                ),
              ),
              IconButton(icon: Icon(Icons.add_box_outlined), onPressed: () {
                showAsset(context, selectedAsset, widget.db, (newAsset) {
                  setState(() {
                    if (newAsset != null) {
                      availableAssets.add(newAsset);
                      portfolioAssets.add(newAsset);
                    }
                  });
                });
              }),
            ],
          ),
          // Modify portfolio's assets
          if (portfolioAssets.isNotEmpty)
            Wrap(spacing: 8,
              children: portfolioAssets.map((asset) =>
                  Chip(label: Text(asset.symbol),
                    onDeleted: () {
                      setState(() {
                        widget.portfolioConfig!.metaIds.remove(asset.id);
                      });
                    },
                  )
              ).toList(),
            ),
          const SizedBox(height: 20),
          FactorSlider(label: r'Target weight [\%]',
            initialValue: targetWeight, minValue: 0.0, maxValue: 1.0,
            onChanged: (double value) {
              setState(() {
                targetWeight = value;
              });
            }
          ),
          FactorSlider(label: r'Rebalance threshold [\%]',
            initialValue: rebalanceThreshold, minValue: 0.0, maxValue: 1.0,
            onChanged: (double value) {
              setState(() {
                rebalanceThreshold = value;
              });
            }
          ),
        ],
      ),
      actions: [
        BackButton(onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(
          onPressed: () {
            portfolioName = controller.text;
            final List<int> newMetaIds = portfolioAssets.map((asset) => asset.id).toList();
            final bewId = widget.portfolioConfig?.id;
            final newPortfolio = PortfolioConfig(id: bewId,
              portfolioName: portfolioName,
              targetWeight: targetWeight,
              rebalanceThreshold: rebalanceThreshold,
              metaIds: newMetaIds,
            );
            widget.onSave(newPortfolio);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }


}
