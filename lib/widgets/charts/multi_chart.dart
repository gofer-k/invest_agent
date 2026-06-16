import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/providers/trading_service.dart';
import 'package:invest_agent/widgets/charts/indicator_overlay_taskbar.dart';
import 'package:invest_agent/widgets/charts/main_overlay_taskbar.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import '../../model/analysis_period.dart';
import '../../model/asset_config.dart';
import '../../model/indicator_result.dart';
import '../../model/indicator_schema.dart';
import '../../model/multi_chart_schema.dart';
import '../../model/price_result.dart';
import '../../providers/load_database_provider.dart';
import '../../providers/multi_chart_provider.dart';
import '../indicator_config_dialog.dart';
import 'controllers/crosshair_controller.dart';
import 'overlay_chart.dart';
import 'overlay_price_chart.dart';
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

  late MultiChartConfig _currentChartConfig = MultiChartConfig.defaultMultiChart();
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
      // Updated: provide the selected chart style to the provider
      ref.read(multiChartProvider(CacheKeyType.analysisCache, _selectedPeriod, _selectedChartStyle).notifier).fetchAll();
    });
    _changeMultiChartConfig(
        newPeriodType: _selectedPeriod,
        newIndicator: _selectedIndicator,
        newStyle: _selectedChartStyle);
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

    if (displayedCharts.isNotEmpty) {
      // Sync local config state with what's actually being displayed to maintain ID
      if (_currentChartConfig.id == -1 || (_currentChartConfig.id != displayedCharts.first.id && displayedCharts.first.asset.id == widget.assetConfig.id)) {
        _currentChartConfig = displayedCharts.first;
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
                                      setState(() => _selectedPeriod = newPeriod);
                                      _chartController.dispose();
                                      _initializeControllers();
                                      _changeMultiChartConfig(newPeriodType: _selectedPeriod);
                                    }
                                  },
                                  onIndicatorChange: (Indicator newIndicator) {
                                    if (newIndicator != _selectedIndicator) {
                                      showIndicator(context, newIndicator,
                                              (Indicator? indicator) {
                                            // TODO: Add new chart in the board
                                            // 1. When indicator.mainChart == true, add a new chart (boRD) or if not add this one into the current chart (overlay one)).
                                            // 2. Request the indicator data from the server.
                                            // 3. Handle the respond the data into the provider's state
                                            // 4. Add the indicator's chart and display it.
                                            // 5. Add overlay indicator config bar to the current chart's board. <- to do onw
                                            if (indicator != null) {
                                              setState(() => _selectedIndicator = indicator);
                                              _changeMultiChartConfig(newIndicator: _selectedIndicator);
                                            }
                                          });
                                    }
                                  },
                                  onChartStyleChange: (ChartStyle newChartStyle) {
                                    if (newChartStyle != _selectedChartStyle) {
                                      setState(() {
                                        _selectedChartStyle = newChartStyle;
                                        _changeMultiChartConfig(newStyle: _selectedChartStyle);
                                      });
                                    }
                                  },
                                ),
                                for (var chart in _currentChartConfig.charts)
                                  if (chart.indicatorConfig.type != IndicatorType.price)
                                    // Expanded(flex: 5,
                                    //   child:
                                      IndicatorOverlayTaskbar(
                                        indicator: chart.indicatorConfig,
                                        onChange: () {
                                          setState(() {
                                            showIndicator(
                                                context, chart.indicatorConfig,
                                                    (Indicator? indicator) {
                                                  // TODO: Handle this case.
                                                });
                                          });
                                        },
                                        onDelete: () {
                                          setState(() {
                                            // _currentChartConfig.charts.remove(chart);
                                          });
                                        }
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
    return const Center(child: Text("No chart configs available"));
  }

  Widget _buildChart(MultiChartConfig chart) {
    final mainChart = chart.mainChart;

    return SyncChart(
      controller: _chartController,
      crosshairController: _crosshairController,
      mainChartConfig: mainChart,
      minFunc: (startDate, endDate) => _getMinValue(mainChart.indicatorConfig.type, _chartController.visibleStart, _chartController.visibleEnd),
      maxFunc: (startDate, endDate) => _getMaxValue(mainChart.indicatorConfig.type, _chartController.visibleStart, _chartController.visibleEnd),
      overLayCharts: [
        _showMainChart(mainChart),
        for(var overlayChart in chart.overlayCharts)
          _showOverlayChart(overlayChart),
        if (widget.showCrosshair)
          OverlayTooltipMarker(overlayType: OverlayType.tooltipMarker, controller: _crosshairController!),
      ]
    );
  }

  OverlayChart _showMainChart(ChartConfig chart) {
    if (chart.indicatorConfig.type == IndicatorType.price) {
      return OverlayPriceChart(data: widget.priceData);
    }
    // TODO: load main's chart an other indicator's data
    // final assetIndicatorResultAsync = ref.watch(assetIndicatorProvider(widget.assetConfig.id, chart.indicatorConfig));
    // return assetIndicatorResultAsync.when(
    //   data: (resultData) {
    //     return LayoutBuilder(builder: (context, constraints) {
    //       final indicatorResult = BaseIndicatorResult(
    //         priceData : resultData,
    //         config: chart.indicatorConfig,
    //         style: chart.chartStyle,
    //       );
    //     };
    //     return OverlayPriceChart(data: resultData, lineColor: AppTheme.of(context).indicatorRate);
    //   },
    //   error: (error, stackTrace) {
    //     return EmptyOverlayChart();
    //   },
    //   loading: () {
    //     return EmptyOverlayChart();
    //   }
    // );
    return EmptyOverlayChart();


    // return switch(chart.indicatorConfig?.type) {
  //     IndicatorType.candlestickPrice =>
  //       OverlayCandlestick(data: widget.results.getPriceData(widget.prefixDomain, _chartController.visibleStart, _chartController.visibleEnd)),
  //     MainChartType.linePrice =>
  //       OverlayPriceChart(data: widget.results.getPriceData(widget.prefixDomain, _chartController.visibleStart, _chartController.visibleEnd)),
  //     MainChartType.macd => OverlayMacd(data: widget.results.getMacd(MACDType.MACD_12_26)),
  //     MainChartType.volume => OverlayVolume(data: widget.results.getPriceData(widget.prefixDomain,  _chartController.visibleStart, _chartController.visibleEnd)),
  //     MainChartType.rsi => OverlayRsi(data: widget.results.getRsi()),
  //     // TODO: Handle this case.
  //     MainChartType.bars => throw UnimplementedError(),
  //   };
  }

  OverlayChart _showOverlayChart(ChartConfig chart) {
    log("Display overlay supplement chart");
    return EmptyOverlayChart();
    //TODO: Display overlay supplement chart
    // return switch (chartType) {
  //     SupplementChart.bb =>
  //       OverlayBellingerBand(
  //           data: widget.results.getBollingerBand(BollingerBandType.lowerBB, 20),
  //           lineColor: AppTheme.of(context).indicatorLowerBand ?? Colors.green),
  //   // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.upperBB, 20),
  //   //     lineColor: AppTheme.of(context).indicatorUpperBand ?? Colors.orangeAccent),
  //   // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.middleBB, 20),
  //   //     lineColor: AppTheme.of(context).indicatorMiddleBand ?? Colors.blueAccent),
  //     SupplementChart.deathCross =>
  //       // TODO: Handle this case.
  //       throw UnimplementedError(),
  //     SupplementChart.goldenCross =>
  //       // TODO: Handle this case.
  //       throw UnimplementedError(),
  //     SupplementChart.ema =>
  //       // TODO: Handle this case.
  //       throw UnimplementedError(),
  //     SupplementChart.emaSignal =>
  //       // TODO: Handle this case.
  //       throw UnimplementedError(),
  //     SupplementChart.obv =>
  //       OverlayOBV(data: widget.results.getPriceData(20, _chartController.visibleStart, _chartController.visibleEnd)),
  //     SupplementChart.sma =>
  //       OverlayMovingAverage(data: widget.results.getSMA(20);
  }

  double _getMaxValue(IndicatorType chartType, DateTime? startDate, DateTime? endDate) {
    final notifier = ref.watch(tradingServiceProvider.notifier);
    return notifier.getMax(chartType, startDate: startDate, endDate: endDate) ?? 0.0;
  }

  double _getMinValue(IndicatorType chartType, DateTime? startDate, DateTime? endDate) {
    final notifier = ref.watch(tradingServiceProvider.notifier);
    return notifier.getMin(chartType, startDate: startDate, endDate: endDate) ?? 0.0;
  }

  Future<bool> _requestIndicator(Indicator indicator) async {
    final notifier = ref.read(tradingServiceProvider.notifier);
    notifier.calculateIndicators(widget.priceData.priceData, [indicator]);

    return true;
  }

  void _changeMultiChartConfig({PeriodType? newPeriodType, ChartStyle? newStyle, Indicator? newIndicator}) {
    final targetPeriod = newPeriodType ?? _selectedPeriod;
    final targetIndicator = newIndicator ?? _selectedIndicator;
    final targetStyle = newStyle ?? _selectedChartStyle;

    final List<ChartConfig> updatedCharts = List.from(_currentChartConfig.charts);

    // if (!found) {
    if (newIndicator != null) {
      updatedCharts.add(
        ChartConfig(
          indicatorConfig: targetIndicator,
          chartStyle: targetStyle,
          mainChart: targetIndicator.isMainChart(),
        ));
    }

    final newChartConfig = _currentChartConfig.copyWith(
      newAsset: widget.assetConfig,
      newPeriodType: targetPeriod,
      newCharts: updatedCharts,
      newTitle: "${widget.assetConfig.symbol} - ${targetPeriod.name} - ${targetStyle.name}",
    );

    if (newChartConfig == _currentChartConfig && newChartConfig.id != -1) return;

    _currentChartConfig = newChartConfig;

    // Use the notifier to persist changes to the database
    final notifier = ref.read(multiChartProvider(
        CacheKeyType.analysisCache,
        targetPeriod,
        targetStyle).notifier);

    if (newChartConfig.id == -1) {
      notifier.addEntry(newChartConfig);
    } else {
      notifier.updateMultiChart(newChartConfig);
    }
  }
}
