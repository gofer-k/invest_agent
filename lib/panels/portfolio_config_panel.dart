import 'dart:core';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/utils/database_helper.dart';

import '../model/asset_config.dart';
import '../model/portfolio_config.dart';
import '../themes/app_themes.dart';
import '../widgets/portfolio_config_dialog.dart';
import '../widgets/utils/shrinkable.dart';
import 'package:path/path.dart' as p;

class PortfolioConfigPanel extends StatefulWidget {
  const PortfolioConfigPanel({super.key});

  @override
  State<StatefulWidget> createState() => _PortfolioConfigPanelState();
}

class _PortfolioConfigPanelState extends State<PortfolioConfigPanel> {
  List<PortfolioConfig> portfolios = [];
  PortfolioConfig? selectedPortfolio;

  List<AssetConfig> assets = [];

  late DatabaseHelper dbHelper;
  String? configFile;
  String? cacheName;

  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final metaIdController = TextEditingController();
  final thresholdController = TextEditingController(text: "0.05");

  Future<void> _loadData() async {
    dbHelper = DatabaseHelper(configFile ?? "");
    dbHelper.init();
    dbHelper.createCache<PortfolioConfig>();
    dbHelper.createCache<AssetConfig>();

    portfolios = await dbHelper.fetchAll<PortfolioConfig>();
    assets = await dbHelper.fetchAll<AssetConfig>();
    if (mounted) {
      setState(() {
        // Update UI after work is done
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    dbHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _loadDataSource(),
          _addPortfolio(),
          for (var portfolio in portfolios)
            _changePortfolio(portfolio),
        ]
      )
    );
  }

  Widget _loadDataSource() {
    return Shrinkable(title: "Load data",
      expanded: true,
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
            onPressed: () => _pickCacheFile("db"),
            child: const Text("Select historical dataset"),
          ),
          const SizedBox(height: 10),
          Text(cacheName ?? "No file selected"),
        ],
      ),
    );
  }
  
  Widget _addPortfolio() {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text("New portfolio"),
          IconButton(icon: Icon(Icons.add), onPressed: (){
            showPortfolio(context, selectedPortfolio, dbHelper, (newPortfolio) {
              setState(() {
                portfolios.add(newPortfolio);
              });
            });
          }),
        ]
    );
  }

  Widget _changePortfolio(PortfolioConfig portfolio) {
    return Shrinkable(title: portfolio.portfolioName,
      actions: [
        IconButton(icon: Icon(Icons.update_outlined),
            onPressed: (){
              showPortfolio(context, portfolio, dbHelper, (newPortfolio) {
                setState(() {
                  final index = portfolios.indexOf(portfolio);
                  if (index != -1) {
                    portfolios[index] = newPortfolio;
                  }
                });
              });
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
          if (portfolio.metaIds.isNotEmpty)
            Wrap(spacing: 8,
              children: assets.where((asset) => portfolio.metaIds.contains(asset.id)).map((asset) =>
                  Chip(label: Text(asset.symbol),
                    onDeleted: () {
                      setState(() {
                        portfolio.metaIds.remove(asset.id);
                        dbHelper.updateOne<PortfolioConfig>(portfolio);
                      });
                    },
                  )
              ).toList(),
            ),
        ],
      ),
    );
  }
  // Widget _buildForm() {
  //   return Form(key: _formKey,
  //     child: Column(
  //       children: [
  //         Shrinkable(title: "Load data",
  //           expanded: true,
  //           body: Column(
  //             children: [
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                     side: BorderSide(width: 1.0, color: AppTheme.of(context).buttonOutlineColor?? Colors.deepPurpleAccent)),
  //                 onPressed: () => _pickCacheFile("db"),
  //                 child: const Text("Select historical dataset"),
  //               ),
  //               const SizedBox(height: 10),
  //               Text(cacheName ?? "No file selected"),
  //             ],
  //           ),
  //         ),
  //         TextFormField(controller: nameController,
  //           decoration: InputDecoration(labelText: 'Portfolio name'),
  //           validator: (value) => (value == null || value.isEmpty) ? 'put a name' : null,),
  //         // TODO: Load list of asset names from the database
  //         // TextFormField(
  //         //   controller: metaIdController,
  //         //   decoration: InputDecoration(labelText: 'Meta ID (FK)'),
  //         //   keyboardType: TextInputType.number,
  //         //   validator: (value) {
  //         //     if (value == null || int.tryParse(value) == null) return 'Podaj poprawne ID';
  //         //     return null;
  //         //   },
  //         // ),
  //         TextFormField(
  //           controller: weightController,
  //           decoration: InputDecoration(labelText: 'Target Weight (0.0 - 1.0)', hintText: 'np. 0.25'),
  //           validator: (value) {
  //             final val = double.tryParse(value ?? '');
  //             if (val == null) return 'NUmber [0-1.0]';
  //             if (val < 0 || val > 1.0) return 'Weight is out of range';
  //             return null;
  //           },
  //         ),
  //         TextFormField(
  //           controller: thresholdController,
  //           decoration: InputDecoration(labelText: 'Rebalance Threshold'),
  //           validator: (value) {
  //             if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
  //               return 'Incorrect format';
  //             }
  //             return null;
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //         Row(
  //           children: [
  //             ElevatedButton(
  //               onPressed: _submitData,
  //               child: Text(selectedPortfolio == null ? 'Add' : 'Update'),
  //             ),
  //             ElevatedButton(
  //               onPressed: _removePortfolio,
  //               child: Text('Remove'),
  //             ),
  //             if (selectedPortfolio != null)
  //               TextButton(
  //                 onPressed: () => setState(() => selectedPortfolio = null),
  //                 child: Text('Cancel'),
  //               ),
  //           ],
  //         ),
  //       ]
  //     )
  //   );
  // }

  Future<void> _pickCacheFile(String extension) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [extension],
      );

      if (result == null || result.files.single.path == null) return;
      // After the await, the widget might be gone.
      if (!mounted) return;

      configFile = result.files.single.path!;
      setState(() {
        cacheName = p.basenameWithoutExtension(result.files.single.path!);
      });
    } catch (e) {
      // After the await (which might have thrown the error), check if the widget is still here.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading file: $e')),
      );
    }
  }
}