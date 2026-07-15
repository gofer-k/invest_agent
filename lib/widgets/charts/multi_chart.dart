import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/trading_service.dart';
import 'package:invest_agent/widgets/charts/indicator_overlay_taskbar.dart';
import 'package:invest_agent/widgets/charts/main_overlay_taskbar.dart';
import 'package:invest_agent/widgets/charts/overlay_ema.dart';
import 'package:invest_agent/widgets/charts/overlay_roc.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import '../../model/analysis_period.dart';
import '../../model/asset_config.dart';
import '../../model/results/analysis_respond.dart';
import '../../model/results/bollinger_bands_result.dart';
import '../../model/results/ema_result.dart';
import '../../model/indicator_result.dart';
import '../../model/indicator_schema.dart';
import '../../model/multi_chart_schema.dart';
import '../../model/results/kst_result.dart';
import '../../model/results/macd_result.dart';
import '../../model/results/price_result.dart';
import '../../model/results/roc_result.dart';
import '../../model/results/rsi_result.dart';
import '../../model/results/sma_result.dart';
import '../../providers/load_database_provider.dart';
import '../../providers/multi_chart_provider.dart';
import '../indicator_config_dialog.dart';
import 'controllers/crosshair_controller.dart';
import 'overlay_bollinger_band.dart';
import 'overlay_chart.dart';
import 'overlay_kst.dart';
import 'overlay_macd.dart';
import 'overlay_price_chart.dart';
import 'overlay_rsi.dart';
import 'overlay_sma.dart';
import 'overlay_tooltip_marker.dart';

class MultiChartView extends ConsumerStatefulWidget {
  final IndexPrice priceData;
  final AssetConfig assetConfig;
  final double chartHeight;
  final bool showCrosshair;
  final int prefixDomain;

  const MultiChartView({
    super.key,
    required this.priceData,
    required this.assetConfig,
    required this.chartHeight,
    this.showCrosshair = true,
    this.prefixDomain = 20, // 20 days before visualize a result data.
  });

  @override
  ConsumerState<MultiChartView> createState() => _MultiChartViewState();
}

class _MultiChartViewState extends ConsumerState<MultiChartView> {
  late TimeController _chartController;
  CrosshairController? _crosshairController;
  Indicator _selectedIndicator = Indicator.priceIndicator();
  PeriodType _selectedPeriod = PeriodType.year;
  ChartStyle _selectedChartStyle = ChartStyle.line;
  //
  // late MultiChartConfig _currentChartConfig = MultiChartConfig
  //     .defaultMultiChart();

  void _initializeControllers() {
    _chartController = TimeController(
        periodType: _selectedPeriod,
        domain: widget.priceData.dateTimeDomain(widget.prefixDomain));
    if (widget.showCrosshair && _crosshairController == null) {
      _crosshairController = CrosshairController();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _selectedChartStyle = widget.priceData.style;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(multiChartProvider(
          CacheKeyType.analysisCache, _selectedPeriod, _selectedChartStyle)
          .notifier).fetchAll();
    });
  }

  @override
  void didUpdateWidget(MultiChartView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.assetConfig != oldWidget.assetConfig) {
      _chartController.dispose();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    if (widget.showCrosshair) {
      _crosshairController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedCharts = ref.watch(multiChartsByProvider(
        CacheKeyType.analysisCache,
        widget.assetConfig,
        _selectedPeriod,
        _selectedChartStyle));

    if (displayedCharts.isEmpty && widget.priceData.priceData.isNotEmpty) {
      print("Empty Displayed chart: $displayedCharts");
      return const Center(child: Text("No chart configs available"));
      // setState(() => _changeMultiChartConfig(
      //   newPeriodType: _selectedPeriod,
      //   newStyle: _selectedChartStyle,
      //   newIndicator: _selectedIndicator)
      // );
    }

    // Sync local config state with what's actually being displayed to maintain ID
    print("Displayed charts: $displayedCharts ");
    final currentChartConfig = displayedCharts.first;
    print("_currentChartConfig: $currentChartConfig} ${currentChartConfig == displayedCharts.first} displayedCharts: $displayedCharts");

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          for (var chart in displayedCharts)
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  _buildChart(chart),
                  if (displayedCharts.first == chart)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        color: Colors.transparent,
                        child:
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainOverlayTaskbar(
                                asset: widget.assetConfig,
                                priceData: widget.priceData,
                                selectedIndicator: _selectedIndicator,
                                selectedPeriod: _selectedPeriod,
                                selectedChartStyle: _selectedChartStyle,
                                onPeriodChange: (PeriodType newPeriod) {
                                  if (newPeriod != _selectedPeriod) {
                                    setState(() =>
                                    _selectedPeriod = newPeriod);
                                    _chartController.dispose();
                                    _initializeControllers();
                                    _changeMultiChartConfig(
                                        activeConfig: currentChartConfig,
                                        newPeriodType: _selectedPeriod);
                                  }
                                },
                                onIndicatorChange: (Indicator newIndicator) {
                                  if (newIndicator != _selectedIndicator) {
                                    showIndicator(context, newIndicator,
                                            (Indicator? indicator) {
                                          if (indicator != null) {
                                            setState(() =>
                                            _selectedIndicator = indicator);
                                            _changeMultiChartConfig(
                                                activeConfig: currentChartConfig,
                                                newIndicator: indicator);
                                          }
                                        });
                                  }
                                },
                                onChartStyleChange: (
                                    ChartStyle newChartStyle) {
                                  if (newChartStyle != _selectedChartStyle) {
                                    setState(() {
                                      _selectedChartStyle = newChartStyle;
                                      _changeMultiChartConfig(
                                          activeConfig: currentChartConfig,
                                          newStyle: _selectedChartStyle);
                                    });
                                  }
                                },
                              ),
                              for (int i = 0; i <
                                  currentChartConfig.charts.length; i++)
                                 if (currentChartConfig.charts[i]
                                    .indicatorConfig.type !=
                                    IndicatorType.price)
                                  IndicatorOverlayTaskbar(
                                      indicator: currentChartConfig.charts[i]
                                          .indicatorConfig,
                                      onChange: () => _handleIndicatorChange(i, currentChartConfig),
                                      onDelete: () => _handleDeleteIndicator(i, currentChartConfig),
                                  )
                            ]
                        ),
                      ),
                    )
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleDeleteIndicator(int index, MultiChartConfig currentConfig) {
    final updatedConfig = currentConfig.copyWith();
    updatedConfig.charts.removeAt(index);

    ref.read(multiChartProvider(
      CacheKeyType.analysisCache,
      _selectedPeriod,
      _selectedChartStyle,
    ).notifier).updateMultiChart(updatedConfig);
  }

  void _handleIndicatorChange(int index, MultiChartConfig currentConfig) {
    showIndicator(context, currentConfig.charts[index].indicatorConfig, (Indicator? updateIndicator) {
      if (updateIndicator != null) {
        // Logic to update the specific chart in the list
        final updatedConfig = currentConfig.copyWith();
        ref.read(multiChartProvider(
          CacheKeyType.analysisCache,
          _selectedPeriod,
          _selectedChartStyle,
        ).notifier).updateMultiChart(updatedConfig);
      }
    });
  }

  Widget _buildChart(MultiChartConfig chart) {
    final mainChart = chart.mainChart;

    List<OverlayChart> availableOverlayCharts = [_showMainChart(mainChart)];
    for (var overlayChart in chart.overlayCharts) {
      // _showOverlayChart(overlayChart),
      if (overlayChart.indicatorConfig.type != IndicatorType.price) {
        availableOverlayCharts.addAll(
            _showOverlayIndicatorCharts(overlayChart));
      }
    }
    if (widget.showCrosshair) {
      availableOverlayCharts.add(OverlayTooltipMarker(
          overlayType: OverlayType.tooltipMarker,
          controller: _crosshairController!));
    }
    return SyncChart(
        controller: _chartController,
        crosshairController: _crosshairController,
        mainChartConfig: mainChart,
        minFunc: (startDate, endDate) =>
            _getMinValue(
            mainChart.indicatorConfig, _chartController.visibleStart,
            _chartController.visibleEnd),
        maxFunc: (startDate, endDate) =>
            _getMaxValue(
            mainChart.indicatorConfig, _chartController.visibleStart,
            _chartController.visibleEnd),
        overLayCharts: availableOverlayCharts
    );
  }

  OverlayChart _showMainChart(ChartConfig chart) {
    if(!chart.mainChart) return EmptyOverlayChart();

    if (chart.indicatorConfig.type == IndicatorType.price) return OverlayPriceChart(data: widget.priceData);
    return _showOverlayIndicatorChart(chart);
  }

  OverlayChart _showOverlayIndicatorChart(ChartConfig chart) {
    final indicatorResultAsync = ref.watch(indicatorResultProvider(
      prices: widget.priceData.priceData,
      indicator: chart.indicatorConfig,
    ));

    return indicatorResultAsync.when(
      data: (result) {
        switch (result?.config.type) {
          case IndicatorType.bollingerBands:
            final bbResult = result as BollingerBandsResult;
            final bbColors = bbResult.config.visibleIndicatorColors();
            return OverlayBollingerBand(
                data: bbResult.getPoints(),
                bollingerBandColors: bbColors);
          case IndicatorType.ema:
            final emaResult = result as EmaResult;
            final emaColors = emaResult.config.visibleIndicatorColors();
            return OverlayExponentialMovingAverage(
                data: emaResult.getPoints(),
                emaColors: emaColors);
          case IndicatorType.kst:
            final kstResult = result as KstResult;
            final kstColors = kstResult.config.visibleIndicatorColors();
            return OverlayKnowSureThing(
                points: kstResult.getPoints(),
                kstColors: kstColors);
          case IndicatorType.macd:
            final macdResult = result as MacdResult;
            final macdColors = macdResult.config.visibleIndicatorColors();
            return OverlayMacd(data: macdResult.getPoints(), macdColors: macdColors);
          case IndicatorType.sma:
            final smaResult = result as SmaResult;
            final smaColors = smaResult.config.visibleIndicatorColors();
            return OverlaySimpleMovingAverage(
                data: smaResult.getPoints(),
                smaColors: smaColors);
          case IndicatorType.roc:
            final rocResult = result as RocResult;
            final rocColors = rocResult.config.visibleIndicatorColors();
            final lowBound = parseNum(Indicator.getParameterValue(rocResult.config.parameters[RocParam.lowerLimit.name]));
            final upperBound = parseNum(Indicator.getParameterValue(rocResult.config.parameters[RocParam.upperLimit.name]));
            return OverlayRoc(
                data: rocResult.getPoints(),
                rocColors: rocColors,
                lowerBound: lowBound,
                upperBound: upperBound);
          case IndicatorType.rsi:
            final rsiResult = result as RsiResult;
            final rsiColors = rsiResult.config.visibleIndicatorColors();
            final lowBound = parseNum(Indicator.getParameterValue(rsiResult.config.parameters[RsiParam.lowerLimit.name]));
            final upperBound = parseNum(Indicator.getParameterValue(rsiResult.config.parameters[RsiParam.upperLimit.name]));
            final baseLevel = parseNum(Indicator.getParameterValue(rsiResult.config.parameters[RsiParam.middleLimit.name]));
            return OverlayRsi(
              data: rsiResult.getPoints(),
              rsiColors: rsiColors,
              lowerBound: lowBound,
              upperBound: upperBound,
              baseLevel: baseLevel);
          case _:
            return EmptyOverlayChart();
        }
      },
      error: (error, stackTrace) {
        log("Error loading indicator: $error");
        return EmptyOverlayChart();
      },
      loading: () => EmptyOverlayChart(),
    );
  }

  List<OverlayChart> _showOverlayIndicatorCharts(ChartConfig chart) {
    return [_showOverlayIndicatorChart(chart)];
  }

  double _getMaxValue(Indicator indicator, DateTime? startDate,
      DateTime? endDate) {
    final notifier = ref.watch(tradingServiceProvider.notifier);
    return notifier.getMax(indicator, startDate: startDate, endDate: endDate) ??
        0.0;
  }

  double _getMinValue(Indicator indicator, DateTime? startDate,
      DateTime? endDate) {
    final notifier = ref.watch(tradingServiceProvider.notifier);
    return notifier.getMin(indicator, startDate: startDate, endDate: endDate) ??
        0.0;
  }

  void _changeMultiChartConfig({
    required MultiChartConfig activeConfig,
    PeriodType? newPeriodType, ChartStyle? newStyle, Indicator? newIndicator}) {
    final targetPeriod = newPeriodType ?? _selectedPeriod;
    final targetIndicator = newIndicator ?? _selectedIndicator;
    final targetStyle = newStyle ?? _selectedChartStyle;

    final List<ChartConfig> updatedCharts = List.from(
        activeConfig.charts);

    if (updatedCharts.isEmpty) {
      updatedCharts.add(ChartConfig(
        indicatorConfig: Indicator.priceIndicator(),
        chartStyle: targetStyle,
        mainChart: true,
      ));
    }

    if (newIndicator != null) {
      final existingIndex = updatedCharts.indexWhere(
              (c) => c.indicatorConfig.type == targetIndicator.type
      );
      final newConfig = ChartConfig(
        indicatorConfig: targetIndicator,
        chartStyle: targetStyle,
        mainChart: targetIndicator.isMainChart(),
      );

      if (existingIndex != -1) {
        print("Try update exists chart ${updatedCharts[existingIndex]} to $newConfig");
        updatedCharts[existingIndex] = newConfig;
      } else {
        print("Add new chart: $newConfig");
        updatedCharts.add(newConfig);
      }
    }

    final newChartConfig = activeConfig.copyWith(
      newAsset: widget.assetConfig,
      newPeriodType: targetPeriod,
      newCharts: updatedCharts,
      newTitle: "${widget.assetConfig.symbol} - ${targetPeriod
          .name} - ${targetStyle.name}",
    );

    final notifier = ref.read(multiChartProvider(
        CacheKeyType.analysisCache,
        targetPeriod,
        targetStyle).notifier);

    if (newChartConfig.id == -1) {
      print("Add chart: $newChartConfig, id: ${newChartConfig.id}");
      notifier.addEntry(newChartConfig);
    } else {
      print("Updating chart: $newChartConfig, id: ${newChartConfig.id}");
      notifier.updateMultiChart(newChartConfig);
    }
  }
}
