import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import '../../model/analysis_period.dart';
import '../../model/asset_config.dart';
import '../../model/indicator_schema.dart';
import '../../model/multi_chart_schema.dart';
import '../../model/price_result.dart';
import '../../providers/load_database_provider.dart';
import '../../providers/multi_chart_provider.dart';
import 'controllers/crosshair_controller.dart';
import 'overlay_chart.dart';
import 'overlay_price_chart.dart';
import 'overlay_tooltip_marker.dart';

class MultiChartView extends ConsumerStatefulWidget {
  final IndexPrice priceData;
  final AssetConfig assetConfig;
  final PeriodType periodType;
  final double chartHeight;
  final bool showCrosshair;
  final int prefixDomain;

  const MultiChartView({
    super.key,
    required this.priceData,
    required this.assetConfig,
    required this.chartHeight,
    this.periodType = PeriodType.year,
    this.showCrosshair = true,
    this.prefixDomain = 20,// 20 days before visualize a result data.
  });

  @override
  ConsumerState<MultiChartView> createState() => _MultiChartViewState();
}

class _MultiChartViewState extends ConsumerState<MultiChartView> {
  late TimeController _chartController;
  CrosshairController? _crosshairController;

  void _initializeControllers() {
    // If you are re-initializing, make sure to dispose the old controller
    // if it's already been created. The 'late' keyword means we can't check for null,
    // so a separate check or a different pattern might be needed if you call this
    // outside of initState/didUpdateWidget. However, in this context,
    // we can assume dispose will be handled correctly.
    _chartController = TimeController(
        periodType: widget.periodType,
        domain: widget.priceData.dateTimeDomain(widget.prefixDomain));
    if (widget.showCrosshair && _crosshairController == null) {
      _crosshairController = CrosshairController();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // This method is called when the parent widget is rebuilt with new properties.
  @override
  void didUpdateWidget(MultiChartView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.assetConfig != oldWidget.assetConfig ||
        widget.periodType != oldWidget.periodType) {
      // Re-initialize the controller with the new data.
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
    final chartConfigs = ref.watch(multiChartsByProvider(
        CacheKeyType.analysisCache,
        widget.assetConfig,
        widget.periodType));

    if (chartConfigs.isNotEmpty) {
      return Padding(padding: EdgeInsets.all(10),
          child: Column(
            children: [
              for (var chart in chartConfigs)
                Expanded(flex: 5, child: _buildChart(chart)),
            ],
          )
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
        _showMainChart(chart.mainChart),
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
    throw UnimplementedError();
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
    return switch (chartType) {
      IndicatorType.price => widget.priceData.getMax(startDate, endDate),
      IndicatorType.macd => 0.0,  // TODO: widget.results.getMaxMACD(MACDType.MACD_12_26, startDate, endDate),
      IndicatorType.volume => 0.0,  // TODO: widget.priceData.getMaxVolume(startDate, endDate),
      IndicatorType.rsi => 0.0, // TODO: widget.results.getMaxRsi(startDate, endDate),
      IndicatorType.bellingerBands => 0.0, // TODO: widget.results.getMaxBollingerBand(BollingerBandType.upperBB, startDate, endDate),
      IndicatorType.sma => throw UnimplementedError(),
      IndicatorType.ema => throw UnimplementedError(),
      IndicatorType.undefined => throw UnimplementedError(),
      IndicatorType.kst => throw UnimplementedError(),
      IndicatorType.roc => throw UnimplementedError(),
    };
  }

  double _getMinValue(IndicatorType chartType, DateTime? startDate, DateTime? endDate) {
    return switch (chartType) {
      IndicatorType.price => widget.priceData.getMin(startDate, endDate),
      IndicatorType.macd => 0.0,  // TODO: widget.results.getMaxMACD(MACDType.MACD_12_26, startDate, endDate),
      IndicatorType.volume => 0.0,  // TODO: widget.priceData.getMaxVolume(startDate, endDate),
      IndicatorType.rsi => 0.0, // TODO: widget.results.getMaxRsi(startDate, endDate),
      IndicatorType.bellingerBands => 0.0, // TODO: widget.results.getMaxBollingerBand(BollingerBandType.upperBB, startDate, endDate),
      IndicatorType.sma => throw UnimplementedError(),
      IndicatorType.ema => throw UnimplementedError(),
      IndicatorType.kst => throw UnimplementedError(),
      IndicatorType.roc => throw UnimplementedError(),
      IndicatorType.undefined => throw UnimplementedError(),
    };
  }
}

