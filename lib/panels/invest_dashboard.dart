import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/asset_config.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/analysis_period.dart';
import 'package:invest_agent/model/charts_configuration.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/providers/indicator_provider.dart';
import 'package:invest_agent/providers/multi_chart_provider.dart';
import 'package:invest_agent/providers/price_controller.dart';
import 'package:invest_agent/widgets/app_logo.dart';
import 'package:invest_agent/widgets/utils/dropdownlist.dart';
import 'package:invest_agent/widgets/utils/task_bar_icon.dart';
import 'package:invest_agent/themes/app_themes.dart';
import 'package:invest_agent/widgets/charts/multi_chart.dart';
import 'package:invest_agent/utils/load_json_data.dart';
import 'package:invest_agent/model/price_result.dart';
import '../model/indicator_result.dart';
import '../providers/load_database_provider.dart';
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
  AnalysisRequest? analysisRequest;
  AnalysisRespond? analysisResult;

  bool isLoading = false;
  String? errorMessage;

  double visibleMinY = 0.0;
  double visibleMaxY = 0.0;
  String chartTitle = "";

  var activePanelIndex = PanelIndex.notUsed;
  AssetConfig _selectedAsset = AssetConfig.defaultAsset();
  PeriodType _selectedPeriod = PeriodType.year;
  ChartStyle _selectedChartStyle = ChartStyle.line;
  
  // TODO: add to the indicator's cache and the visualization config
  Indicator _selectedIndicator = Indicator.defaultIndicator();
  final Indicator _priceConfig = Indicator.priceIndicator();
  final List<Indicator> _displayedIndicators = [];
  final List<MultiChartConfig> _displayedCharts = [];
  late MultiChartConfig _currentChartConfig = MultiChartConfig.defaultMultiChart();

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
    ref.listen<List<Indicator>>(sortedIndicatorsProvider, (previous, next) {
      if (!_selectedIndicator.isDefault() && next.isNotEmpty) {
        setState(() {
          _selectedIndicator = next.first;
        });
      }
    });
    ref.listen<List<MultiChartConfig>>(multiChartsByProvider(
        CacheKeyType.analysisCache, _selectedAsset, _selectedPeriod), (previous, next) {
      if (previous != next && next.isNotEmpty) {
          _displayedCharts.clear();
          _displayedCharts.addAll(next);
          _currentChartConfig = _displayedCharts.last;
          _selectedPeriod = _currentChartConfig.periodType;
      }
    });

    if (_displayedCharts.isEmpty) {
      _changeMultiChartConfig(
        newAsset: _selectedAsset,
        newPeriodType: _selectedPeriod,
        newIndicator: _priceConfig);
    }

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
                const SizedBox(width: 4,),
                _displayIndicatorsList(),
                const SizedBox(width: 4,),
                _displayChartStyles(),
                const SizedBox(width: 4,),
                _displayPeriodList(),
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
          if (!_selectedAsset.isDefault()) {
            _changeMultiChartConfig(newAsset: _selectedAsset);
          }
        });
      },
      choiceType: _selectedAsset, 
      choices: assets,
    ); 
  }

  Widget _displayIndicatorsList() {
    final indicators = ref.watch(sortedIndicatorsProvider);

    return DropdownList<Indicator>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (Indicator indicator) {
        setState(() {
          _selectedIndicator = indicator;
          if (!_selectedIndicator.isDefault()) {
            _changeMultiChartConfig(newIndicator: _selectedIndicator);
          }
        });
      },
      choiceType: indicators.contains(_selectedIndicator)
          ? _selectedIndicator
          : (indicators.isNotEmpty ? indicators.first : _selectedIndicator),
        choices: indicators,
    );
  }

  Widget _displayPeriodList() {
    final periods = PeriodType.values.toList();
    return DropdownList<PeriodType>(
      textStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (PeriodType period) {
        if (_selectedPeriod == period) return;
        setState(() {
          _selectedPeriod = period;
          _changeMultiChartConfig(newPeriodType: _selectedPeriod);
        });
      },
      choiceType: periods.contains(_selectedPeriod)
          ? _selectedPeriod
          : periods.first,
      choices: periods,
    );
  }

  Widget _displayChartStyles() {
    final styles = ChartStyle.values.toList();
    return DropdownList<ChartStyle>(
      textStyle: Theme.of(context).textTheme.labelLarge,
        backgroundColor:  Colors.grey.shade600.withAlpha(128),
      onSelected: (ChartStyle style) {
        if (_selectedChartStyle == style) return;
        setState(() {
          _selectedChartStyle = style;
          _changeMultiChartConfig(newChartStyle :_selectedChartStyle);
        });
      },
      choiceType: styles.contains(_selectedChartStyle)
          ? _selectedChartStyle
          : styles.first,
      choices: styles.toList()
    );
  }

  void _changeMultiChartConfig({AssetConfig? newAsset, PeriodType? newPeriodType,
    ChartStyle? newChartStyle, Indicator? newIndicator}) {

    final targetAsset = newAsset ?? _selectedAsset;
    final targetPeriod = newPeriodType ?? _selectedPeriod;
    if (targetAsset.isDefault()) return;

    final List<ChartConfig> updatedCharts = List.from(_currentChartConfig.charts);
    if (newIndicator != null && !updatedCharts.any((c) => c.indicatorConfig == newIndicator)) {
      updatedCharts.add(
        ChartConfig(
          indicatorConfig: newIndicator,
          chartStyle: newChartStyle ?? ChartStyle.line,
          mainChart: newIndicator.isMainChart(),
          drawingData: [
            //TODO: add user's drawing features in the current chart
          ]
       ));
    }

    final newIndicatorConfig =_currentChartConfig.copyWith(
      newAsset: targetAsset,
      newPeriodType: targetPeriod,
      newCharts: updatedCharts,
      newTitle: "${targetAsset.symbol} - ${targetPeriod.name} - ${(newChartStyle ?? _selectedChartStyle).name}",
    );

    // Update the multi chart in the cache
    if (newIndicatorConfig == _currentChartConfig) return;

    final notifier = ref.read(multiChartProvider(CacheKeyType.analysisCache, targetPeriod).notifier);
    if (newIndicatorConfig.id  < 0) {
      notifier.addEntry(newIndicatorConfig);
    } else {
      notifier.updateMultiChart(newIndicatorConfig);
    }
  }

  Future<AnalysisRespond?> receiveCompressedAnalysisResult(Map<String, dynamic> result) {
    final filePath = result["response_file"];
    final data = loadFinancialDataFromGzip(filePath);

    return data;
  }

  // Build the analysis panel UI
  Widget _buildAnalysisPanel(WidgetRef ref) {
    //TODO: add floating charts configs
    // _displayedCharts = ref.read(multiChartsByProvider(CacheKeyType.analysisCache, _selectedAsset, _selectedPeriod));

    if (!_selectedAsset.isDefault()) {
      //----
      final assetPriceAsync = ref.watch(assetPricesProvider(_selectedAsset.id));
      return assetPriceAsync.when(
        data: (priceData) {
          if (priceData.isEmpty) {
            return const Center(child: Text("No data available"));
          }
          return LayoutBuilder(builder: (context, constraints) {
            final priceResult = IndexPrice(
                priceData : priceData,
                config: _priceConfig,
                style: _selectedChartStyle,
            );
            return MultiChartView(
              priceData: priceResult,
              assetConfig: _selectedAsset,
              periodType: _selectedPeriod,
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
    //----

    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (errorMessage != null) {
    //   return Center(
    //     child: Text(
    //       "Error: $errorMessage",
    //       style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    //     ),
    //   );
    // }

    // final AnalysisRespond? currentResult = analysisResult;
    // if (currentResult == null) {
    //   return const Center(
    //     child: Text("Run analysis to see results"),
    //   );
    // }
    // final currentRequest = analysisRequest;
    // if (analysisRequest == null) {
    //   return const Center(
    //     child: Text("Run analysis to see settings"),
    //   );
    // }

    // return LayoutBuilder(builder: (context, constraints) {
    //   if (currentRequest != null) {
    //     return MultiChartView(
    //         chartTitle: [currentRequest.symbolTicker],
    //         analysisRequest: currentRequest,
    //         results: currentResult,
    //         chartConfig: configurationCharts,
    //         chartHeight: constraints.maxHeight);
    //     }
    //     return const Center(child: Text("No analysis to see results"));
    //   }
  }
}
