import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/charts_configuration.dart';
import 'package:invest_agent/model/results/analysis_respond.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:invest_agent/widgets/app_logo.dart';
import 'package:invest_agent/widgets/utils/dropdownlist.dart';
import 'package:invest_agent/widgets/utils/task_bar_icon.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import 'package:invest_agent/model/results/indicator/price_result.dart';
import '../model/chart_style.dart';
import '../providers/model_config.dart';
import 'analysis_settings_panel.dart';
import 'main_settings_panel.dart';
import '../widgets/app_task_bar.dart';

enum LeftPaneIndex {
  mainSettings("Main Settings"),
  request("Request"),
  results("Results"),
  notUsed("");

  const LeftPaneIndex(this.name);
  final String name;
}

enum RightPaneIndex {
  analysisResults("Analysis results"),
  notUsed("");

  const RightPaneIndex(this.name);
  final String name;
}

class InvestDashboard extends ConsumerStatefulWidget {
  const InvestDashboard({super.key});

  @override
  ConsumerState<InvestDashboard> createState() => _InvestDashboardState();
}

class _InvestDashboardState extends ConsumerState<InvestDashboard> {
  ChartsConfiguration configurationCharts = ChartsConfiguration();
  AnalysisRespond? analysisResult;

  bool isLoading = false;
  String? errorMessage;
  String chartTitle = "";

  var activeLeftPaneIndex = LeftPaneIndex.notUsed;
  var activeRightPaneIndex = RightPaneIndex.notUsed;
  AssetConfig _selectedAsset = AssetConfig.defaultAsset();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<AssetConfig>>(sortedAssetsProvider, (previous, next) {
      if (_selectedAsset.isDefault() && next.isNotEmpty) {
        setState(() {
          _selectedAsset = next.first;
        });
      }
    });

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
                AppLogo(size: 24, color: AppTheme.of(context).indicatorRate),
                const SizedBox(width: 24,),
                _displayAssetsList(),
              ],
              overflowActions: [
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
                    color: activeLeftPaneIndex == LeftPaneIndex.mainSettings ? AppTheme.of(context).taskHighlightColor : null,
                    onPressed: () => _toggleVerticalLeftPanel(LeftPaneIndex.mainSettings),
                  ),
                  const Divider(height: 20, indent: 8, endIndent: 8),
                  TaskBarIcon(icon: Icons.bar_chart,
                      tooltip: 'Analysis results',
                      color: activeRightPaneIndex == RightPaneIndex.analysisResults ? AppTheme.of(context).taskHighlightColor : null,
                      onPressed: () => _toggleVerticalRightPane(RightPaneIndex.analysisResults)),
                ],
                overflowActions: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, size: 20),
                    title: const Text('Help'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),

              _buildLeftPane(),
              Expanded(flex: 4, child: _buildMainPane(ref)),
              _buildRightPane(),
            ],
        ),
    );
  }

  void _toggleVerticalLeftPanel(LeftPaneIndex index) {
    setState(() {
      if (activeLeftPaneIndex == index) {
        activeLeftPaneIndex = LeftPaneIndex.notUsed; // Hide if same icon clicked
      } else {
        activeLeftPaneIndex = index; // Switch to new panel
      }
    });
  }

  void _toggleVerticalRightPane(RightPaneIndex index) {
    setState(() {
      if (activeRightPaneIndex == index) {
        activeRightPaneIndex = RightPaneIndex.notUsed; // Hide if same icon clicked
      } else {
        activeRightPaneIndex = index; // Switch to new panel
      }
    });
  }

  Widget _buildLeftPane() {
    if (activeLeftPaneIndex != LeftPaneIndex.notUsed) {
      return SizedBox(
        width: 350,
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme
                .of(context)
                .dividerColor)),
          ),
          child: Column(
            children: [
              // Panel Header with Hide Icon
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? const Color(0xFF3C3F41)
                    : const Color(0xFFF2F2F2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activeLeftPaneIndex.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hide settings',
                      onPressed: () =>
                          setState(() =>
                          activeLeftPaneIndex = LeftPaneIndex.notUsed),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildSettingsActivePanel()),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildRightPane() {
    if (activeRightPaneIndex != RightPaneIndex.notUsed) {
      return SizedBox(
        width: 350,
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Theme
                .of(context)
                .dividerColor)),
          ),
          child: Column(
            children: [
              // Panel Header with Hide Icon
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? const Color(0xFF3C3F41)
                    : const Color(0xFFF2F2F2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activeRightPaneIndex.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hide results',
                      onPressed: () =>
                          setState(() =>
                          activeRightPaneIndex = RightPaneIndex.notUsed),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildAnalysisResults()),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildSettingsActivePanel() {
    switch (activeLeftPaneIndex) {
      case LeftPaneIndex.mainSettings:
        return const MainSettingsPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnalysisResults() {
    return const AnalysisSettingsPanel();
  }
  
  Widget _displayAssetsList() {
    final assets = ref.watch(sortedAssetsProvider);
    return DropdownList<AssetConfig>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (AssetConfig asset) {
        setState(() {
          _selectedAsset = asset;
        });
      },
      choiceType: _selectedAsset, 
      choices: assets,
    ); 
  }

  // Build the analysis panel UI
  Widget _buildMainPane(WidgetRef ref) {
    if (!_selectedAsset.isDefault()) {
      final assetPriceAsync = ref.watch(assetPricesProvider(_selectedAsset.id));
      return assetPriceAsync.when(
        data: (priceData) {
          if (priceData.isEmpty) {
            return const Center(child: Text("No data available"));
          }
          return LayoutBuilder(builder: (context, constraints) {
            final priceResult = IndexPrice(
                priceData : priceData,
                config: Indicator.priceIndicator(),
                style: ChartStyle.line,
            );
            return MultiChartView(
              priceData: priceResult,
              assetConfig: _selectedAsset,
              chartHeight: constraints.maxHeight,
              prefixDomain: 0); // TODO: check out this
              // prefixDomain: _selectedIndicator.isDefault() ? 0 : 20);
            }
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text("Error: $error",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator())
      );
    }
    return const Center(child: Text("Run analysis to see settings"));
  }
}
