import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import '../model/asset_config.dart';
import '../model/charts_configuration.dart';
import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';

import '../model/index_price.dart';
import '../model/indicator_schema.dart';
import '../providers/indicator_provider.dart';
import '../providers/model_config.dart';
import '../providers/price_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/utils/dropdownlist.dart';
import '../widgets/utils/task_bar_icon.dart';
import 'analysis_settings_panel.dart';
import 'etf_settings_charts.dart';
import 'request_settings_panel.dart';
import 'main_settings_panel.dart';
import '../widgets/app_task_bar.dart';

enum PanelIndex {
  mainSettings("Main Settings"),
  analysisSettings("Analysis Settings"),
  request("Request"),
  results("Results"),
  notUsed("");

  const PanelIndex(this.name);
  final String name;
}

class InvestDashboard extends ConsumerStatefulWidget {
  const InvestDashboard({super.key});

  @override
  ConsumerState<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends ConsumerState<InvestDashboard> {
  ChartsConfiguration configurationCharts = ChartsConfiguration();
  AnalysisRequest? analysisRequest;
  AnalysisRespond? analysisResult;

  bool isLoading = false;
  String? errorMessage;

  double visibleMinY = 0.0;
  double visibleMaxY = 0.0;
  String chartTitle = "";

  var activePanelIndex = PanelIndex.notUsed;
  AssetConfig _selectedAsset = AssetConfig.defaultAsset();
  Indicator _selectedIndicator = Indicator.defaultIndicator();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to update the selected asset when data is first loaded
    ref.listen<List<AssetConfig>>(sortedAssetsProvider, (previous, next) {
      if (_selectedAsset.isDefault() && next.isNotEmpty) {
        setState(() {
          _selectedAsset = next.first;
        });
      }
    });

    // ref.listen<AsyncValue<List<Indicator>>>(indicatorProvider(), (previous, next) {
    //   if (_selectedIndicator.isDefault() && next.value != null) {
    //     setState(() {
    //       _selectedIndicator = next.value?.first ?? Indicator.defaultIndicator();
    //     });
    //   }
    // });

   return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.of(context).barColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).borderColor ?? Colors.transparent,
            width: 1,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(child: AppHorizontalTaskBar(
              mainActions: [
                AppLogo(size: 24, color: Theme.of(context).splashColor),
                const SizedBox(width: 24,),
                _displayAssetsList(),
                const SizedBox(width: 4,),
                // _displayIndicatorsList(),
                VerticalDivider(width: 1, thickness: 1,color: Theme.of(context).dividerColor),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("Placeholder", style: Theme.of(context).textTheme.labelLarge),
                ),
              ],),
            ),
          ],
        ),
      ),
      body:
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // VERTICAL TASK BAR ON THE LEFT
              AppVerticalTaskBar(
                mainActions: [
                  // TAB ACTIONS MOVED TO VERTICAL BAR
                  TaskBarIcon(
                    icon: Icons.settings,
                    tooltip: 'Main Settings',
                    color: activePanelIndex == PanelIndex.mainSettings ? Theme.of(context).primaryColor : null,
                    onPressed: () => _toggleVerticalPanel(PanelIndex.mainSettings),
                  ),
                  const Divider(height: 20, indent: 8, endIndent: 8),
                  TaskBarIcon(icon: Icons.bar_chart,
                      tooltip: 'Analysis Settings',
                      color: Theme.of(context).primaryColor,
                      onPressed: () => _toggleVerticalPanel(PanelIndex.analysisSettings)),
                  // TODO: remove below ones
                  const Divider(height: 20, indent: 8, endIndent: 8),
                  TaskBarIcon(
                    icon: Icons.settings,
                    tooltip: 'Request Settings',
                    color: activePanelIndex == PanelIndex.request ? Theme.of(context).primaryColor : null,
                    onPressed: () => _toggleVerticalPanel(PanelIndex.request),
                  ),
                  TaskBarIcon(
                    icon: Icons.update,
                    tooltip: 'Results Settings',
                    color: activePanelIndex == PanelIndex.results ? Theme.of(context).primaryColor : null,
                    onPressed: () => _toggleVerticalPanel(PanelIndex.results),
                  ),
                ],
                overflowActions: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, size: 20),
                    title: const Text('Help'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),

              // COLLAPSIBLE SIDE PANEL
              if (activePanelIndex != PanelIndex.notUsed)
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                    ),
                    child: Column(
                      children: [
                        // Panel Header with Hide Icon
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3C3F41)
                              : const Color(0xFFF2F2F2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(activePanelIndex.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Hide Panel',
                                onPressed: () => setState(() => activePanelIndex = PanelIndex.notUsed),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildActivePanel()),
                      ],
                    ),
                  ),
                ),

              // MAIN ANALYSIS PANEL
              Expanded(
                flex: 4,
                child: _buildAnalysisPanel(),
              ),
            ],
        ),
    );
  }

  void _toggleVerticalPanel(PanelIndex index) {
    setState(() {
      if (activePanelIndex == index) {
        activePanelIndex = PanelIndex.notUsed; // Hide if same icon clicked
      } else {
        activePanelIndex = index; // Switch to new panel
      }
    });
  }

  Widget _buildActivePanel() {
    switch (activePanelIndex) {
      case PanelIndex.request:
        return RequestSettingsPanel(onRunAnalysis: (AnalysisRequest request) => {});
      case PanelIndex.results:
        return EtfSettingsCharts(
          configurationCharts: configurationCharts,
          onConfigAnalysis: _handleConfigAnalysis,
        );
      case PanelIndex.mainSettings:
        return const MainSettingsPanel();
      case PanelIndex.analysisSettings:
        return const AnalysisSettingsPanel();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _displayAssetsList() {
    final assets = ref.watch(sortedAssetsProvider);
    return DropdownList<AssetConfig>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (AssetConfig asset) {
        setState(() {
          _selectedAsset = asset;
          if (!_selectedAsset.isDefault()) {
            ref.read(priceControllerProvider().notifier).fetchOne(
                IndexPriceSchema(),
                IndexPrice.of(
                  assetId: _selectedAsset.id,
                  dateTime: DateTime.now()));
          }
        });
      },
      choiceType: _selectedAsset, 
      choices: assets,
    ); 
  }

  Widget _displayIndicatorsList() {
    final indicators = ref.watch(indicatorProvider()).value ?? [];
    return DropdownList<Indicator>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (Indicator indicator) {
        setState(() {
          _selectedIndicator = indicator;
          if (!_selectedIndicator.isDefault()) {
            // ref.read(priceControllerProvider.notifier).fetchOne(
            //     IndexPriceSchema(),
            //     IndexPrice.of(
            //         assetId: _selectedIndicator.id,
            //         dateTime: DateTime.now()));
          }
        });
      },
      choiceType: _selectedIndicator,
      choices: indicators,
    );
  }

  Future<void> _handleConfigAnalysis(ChartsConfiguration config) async {
    setState(() {
      configurationCharts = config;
    });
  }

  Future<AnalysisRespond?> receiveCompressedAnalysisResult(Map<String, dynamic> result) {
    final filePath = result["response_file"];
    final data = loadFinancialDataFromGzip(filePath);

    return data;
  }

  // Build the analysis panel UI
  Widget _buildAnalysisPanel() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          "Error: $errorMessage",
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final AnalysisRespond? currentResult = analysisResult;
    if (currentResult == null) {
      return const Center(
        child: Text("Run analysis to see results"),
      );
    }
    final currentRequest = analysisRequest;
    if (analysisRequest == null) {
      return const Center(
        child: Text("Run analysis to see settings"),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (currentRequest != null) {
        return MultiChartView(
            chartTitle: [currentRequest.symbolTicker],
            analysisRequest: currentRequest,
            results: currentResult,
            chartConfig: configurationCharts,
            chartHeight: constraints.maxHeight);
        }
        return const Center(child: Text("No analysis to see results"));
      }
    );
  }
}
