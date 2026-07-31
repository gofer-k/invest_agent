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
import 'package:invest_agent/model/results/price_result.dart';
import '../model/chart_style.dart';
import '../providers/model_config.dart';
import 'analysis_settings_panel.dart';
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
  AnalysisRespond? analysisResult;

  bool isLoading = false;
  String? errorMessage;
  String chartTitle = "";

  var activePanelIndex = PanelIndex.notUsed;
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
                    color: activePanelIndex == PanelIndex.mainSettings ? AppTheme.of(context).taskHighlightColor : null,
                    onPressed: () => _toggleVerticalPanel(PanelIndex.mainSettings),
                  ),
                  const Divider(height: 20, indent: 8, endIndent: 8),
                  TaskBarIcon(icon: Icons.bar_chart,
                      tooltip: 'Analysis Settings',
                      color: activePanelIndex == PanelIndex.analysisSettings ? AppTheme.of(context).taskHighlightColor : null,
                      onPressed: () => _toggleVerticalPanel(PanelIndex.analysisSettings)),
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
                        Expanded(child: _buildSettingsActivePanel()),
                      ],
                    ),
                  ),
                ),

              // MAIN ANALYSIS PANEL
              Expanded(
                flex: 4,
                child: _buildAnalysisPanel(ref),
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

  Widget _buildSettingsActivePanel() {
    switch (activePanelIndex) {
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
        });
      },
      choiceType: _selectedAsset, 
      choices: assets,
    ); 
  }

  // Build the analysis panel UI
  Widget _buildAnalysisPanel(WidgetRef ref) {
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
