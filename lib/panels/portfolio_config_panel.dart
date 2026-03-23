import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:invest_agent/utils/database_helper.dart';
import '../model/portfolio_config.dart';
import '../widgets/portfolio_config_dialog.dart';
import '../widgets/utils/shrinkable.dart';

class PortfolioConfigPanel extends StatefulWidget {
  final DatabaseHelper? dbHelper;

  const PortfolioConfigPanel(this.dbHelper, {super.key});

  @override
  State<StatefulWidget> createState() => _PortfolioConfigPanelState();
}

class _PortfolioConfigPanelState extends State<PortfolioConfigPanel> {
  List<PortfolioConfig> portfolios = [];
  PortfolioConfig? selectedPortfolio;

  String? configFile;
  String? cacheName;

  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final metaIdController = TextEditingController();
  final thresholdController = TextEditingController(text: "0.05");

  Future<void> _loadData() async {
    try {
      final dbPortfolios = await widget.dbHelper?.fetchAll<PortfolioConfig>(
          PortfolioConfigSchema());

      if (mounted) {
        setState(() {
          // Update UI after work is done
          portfolios = dbPortfolios!;
        });
      }
    }
    catch (e) {
      log('Error loading portfolio data: $e', time: DateTime.now());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Shrinkable(title: "Portfolios",
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _addPortfolio(),
          for (var portfolio in portfolios)
            _changePortfolio(portfolio),
          ]
        )
      )
    );
  }

  Widget _addPortfolio() {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text("New portfolio"),
          IconButton(icon: Icon(Icons.add), onPressed: (){
            if (widget.dbHelper != null) {
              showPortfolio(
                  context, selectedPortfolio, widget.dbHelper!, (newPortfolio) {
                setState(() {
                  portfolios.add(newPortfolio);
                });
              });
            }
          }),
        ]
    );
  }

  Widget _changePortfolio(PortfolioConfig portfolio) {
    return Shrinkable(title: portfolio.portfolioName,
      actions: [
        IconButton(icon: Icon(Icons.update_outlined),
            onPressed: (){
              if (widget.dbHelper != null) {
                showPortfolio(context, portfolio, widget.dbHelper!, (newPortfolio) {
                  setState(() {
                    final index = portfolios.indexOf(portfolio);
                    if (index != -1) {
                      portfolios[index] = newPortfolio;
                    }
                  });
                });
              }
            }),
        IconButton(icon: Icon(Icons.remove_outlined),
            onPressed: (){
              setState(() {
                portfolios.remove(portfolio);
              });
            }),
      ],
      expanded: true,
      body: Column(
        children: [
          Text(portfolio.portfolioName, style: Theme.of(context).textTheme.titleLarge),
          // TODO:
          // if (portfolio.metaIds.isNotEmpty)
          //   Wrap(spacing: 8,
          //     children: assets.where((asset) => portfolio.metaIds.contains(asset.id)).map((asset) =>
          //         Chip(label: Text(asset.symbol),
          //           onDeleted: () {
          //             setState(() {
          //               portfolio.metaIds.remove(asset.id);
          //               dbHelper.updateOne<PortfolioConfig>(PortfolioConfigSchema(), portfolio);
          //             });
          //           },
          //         )
          //     ).toList(),
          //   ),
        ],
      ),
    );
  }
}
