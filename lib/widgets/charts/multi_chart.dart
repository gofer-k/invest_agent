import 'dart:async';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final availableCharts = await ref.read(multiChartProvider(
          CacheKeyType.analysisCache, _selectedPeriod, _selectedChartStyle)
          .notifier).fetchAll();

      if (availableCharts.isEmpty) {
        final priceChart = MultiChartConfig.priceMultiChart(widget.assetConfig,
            _selectedPeriod, _selectedChartStyle);
        _changeMultiChartConfig(activeConfig: priceChart, newActiveChart: true);
      }
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

    if (widget.priceData.priceData.isEmpty) {
      return Center(child: Text("No ${widget.assetConfig.symbol} available price data"));
    }

    for (var multiChart in displayedCharts) {
      _showResultErrorMessage(multiChart);
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          for (var chart in displayedCharts)
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Checkbox.adaptive(value: chart.activeChart,
                    onChanged: (selectedChart) {
                      if (selectedChart == null) return;
                      // modify the active chart but the only one chart is displayed
                      if (displayedCharts.length > 1 && selectedChart != chart.activeChart) {
                        setState(() {
                          //TODO: sync all of the multi charts (config) with the new active chart
                          _changeMultiChartConfig(activeConfig: chart, newActiveChart: selectedChart);
                          final newActiveChart = displayedCharts.firstWhere((elem) {
                            if (chart != elem && !elem.activeChart) {
                              return true;
                            }
                            return false;
                          });
                          _changeMultiChartConfig(activeConfig: newActiveChart, newActiveChart: true);
                        });
                      }
                    })
                  ),
                  _buildChart(chart, currentChart: chart.activeChart),
                  if (chart.hasPriceChart)
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
                                    //TODO: sync all of the multi charts (config) with the new period
                                    _changeMultiChartConfig(
                                        activeConfig: chart,
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
                                          if (indicator.isMainChart()) {
                                            _changeMultiChartConfig(
                                              activeConfig: MultiChartConfig.defaultMultiChart(asset: widget.assetConfig),
                                              newIndicator: indicator,
                                              newActiveChart: true,
                                              newStyle: _selectedChartStyle,
                                              newPeriodType: _selectedPeriod
                                            );
                                          }
                                          else {
                                            _changeMultiChartConfig(
                                                activeConfig: chart,
                                                newIndicator: indicator);
                                          }
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
                                          activeConfig: chart,
                                          newStyle: _selectedChartStyle);
                                    });
                                  }
                                },
                              ),
                              for (int i = 0; i <
                                  chart.charts.length; i++)
                                 if (chart.charts[i]
                                    .indicatorConfig.type !=
                                    IndicatorType.price)
                                  IndicatorOverlayTaskbar(
                                      indicator: chart.charts[i]
                                          .indicatorConfig,
                                      onChange: () => _handleIndicatorChange(i, chart),
                                      onDelete: () => _handleDeleteIndicator(i, chart),
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

  void _showResultErrorMessage(MultiChartConfig multiChartConfig) {
    for (var chart in multiChartConfig.charts) {
      ref.listen(indicatorResultProvider(
        prices: widget.priceData.priceData,
        indicator: chart.indicatorConfig,
      ), (previous, next) {
        next.whenOrNull(
          error: (error, stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load ${chart.indicatorConfig.name}: $error',
                  style: Theme.of(context).textTheme.labelMedium),
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      });
    }
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
        final formerIndicatorMainChart = currentConfig.charts[index].indicatorConfig.isMainChart();
        final updatedIndicatorMainChart = updateIndicator.isMainChart();
        final List<ChartConfig> updatedCharts = List.from(currentConfig.charts);

        // currentConfig not changed main chart state
        if (formerIndicatorMainChart == updatedIndicatorMainChart) {
          final updateChart = currentConfig.charts[index].copyWith(
              newIndicatorConfig: updateIndicator,
              mainChart: updatedIndicatorMainChart
          );
          updatedCharts[index] = updateChart;
          final updatedConfig = currentConfig.copyWith(newCharts: updatedCharts,
              newActiveChart: updatedIndicatorMainChart);
          ref.read(multiChartProvider(
            CacheKeyType.analysisCache,
            _selectedPeriod,
            _selectedChartStyle,
          ).notifier).updateMultiChart(updatedConfig);
        }
        // currentConfig changed main chart state
        else {
          // Migrate current indicator to the main one
          if (updatedIndicatorMainChart) {
            updatedCharts.removeAt(index);
            final shrinkConfig = currentConfig.copyWith(newCharts: updatedCharts,
                newActiveChart: formerIndicatorMainChart);
            ref.read(multiChartProvider(
              CacheKeyType.analysisCache,
              _selectedPeriod,
              _selectedChartStyle,
            ).notifier).updateMultiChart(shrinkConfig);

            final updatedIndicator = updateIndicator.copyWith(isMainChart: true);
            ref.read(multiChartProvider(CacheKeyType.analysisCache,
              _selectedPeriod, _selectedChartStyle).notifier).addEntry(
                currentConfig.copyWith(
                  newId: MultiChartConfig.defaultId,
                  newTitle: "${currentConfig.toString()} - ${updatedIndicator.name}",
                  newCharts: [
                    ChartConfig(
                      mainChart: updatedIndicatorMainChart,
                      chartStyle: ChartStyle.line,  // TODO: support customized indicator's chart style
                      indicatorConfig: updatedIndicator)]
                ));
          }
          // remove updated currentConfig with main chart from the cache
          else {
            ref.read(multiChartProvider(
              CacheKeyType.analysisCache,
              _selectedPeriod,
              _selectedChartStyle,
            ).notifier).deleteEntry(currentConfig);
          }
        }


      }
    });
  }

  Widget _buildChart(MultiChartConfig chart, {required bool currentChart}) {
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
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: currentChart ? Colors.blueGrey : Colors.transparent, width: 2.0)),
      child: SyncChart(
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
      )
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
      error: (error, stackTrace) => EmptyOverlayChart(),
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
    PeriodType? newPeriodType, ChartStyle? newStyle, Indicator? newIndicator, bool? newActiveChart}) {
    final targetPeriod = newPeriodType ?? _selectedPeriod;
    final targetIndicator = newIndicator ?? _selectedIndicator;
    final targetStyle = newStyle ?? _selectedChartStyle;

    final List<ChartConfig> updatedCharts = List.from(
        activeConfig.charts);

    if (newIndicator != null) {
      final existingIndex = updatedCharts.indexWhere(
              (c) => c.indicatorConfig.type == targetIndicator.type
      );
      final newConfig = ChartConfig(
        indicatorConfig: targetIndicator,
        chartStyle: targetStyle,
        mainChart: targetIndicator.isMainChart(),
      );

      if (existingIndex != -1 ) {
        updatedCharts[existingIndex] = newConfig;
      } else {
        updatedCharts.add(newConfig);
      }
    }

    final newChartConfig = activeConfig.copyWith(
      newAsset: widget.assetConfig,
      newPeriodType: targetPeriod,
      newActiveChart: newActiveChart,
      newCharts: updatedCharts,
      newTitle: "${widget.assetConfig.symbol} - ${targetPeriod
          .name} - ${targetStyle.name}",
    );

    final notifier = ref.read(multiChartProvider(
        CacheKeyType.analysisCache,
        targetPeriod,
        targetStyle).notifier);

    if (newChartConfig.id == MultiChartConfig.defaultId) {
      notifier.addEntry(newChartConfig);
    } else {
      notifier.updateMultiChart(newChartConfig);
    }
  }
}
