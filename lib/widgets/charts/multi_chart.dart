import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/model/charts_configuration.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import '../../themes/app_themes.dart';
import 'controllers/crosshair_controller.dart';
import 'overlay_bellinger_band.dart';
import 'overlay_candlestick.dart';
import 'overlay_chart.dart';
import 'overlay_macd.dart';
import 'overlay_moving_average.dart';
import 'overlay_obv.dart';
import 'overlay_price_chart.dart';
import 'overlay_rsi.dart';
import 'overlay_tooltip_marker.dart';
import 'overlay_volume.dart';

class MultiChartView extends StatefulWidget {
  final List<String> chartTitle;
  final AnalysisRequest analysisRequest;
  final ChartsConfiguration chartConfig;
  final AnalysisRespond results;
  final double chartHeight;
  final bool showCrosshair;
  final int prefixDomain;

  const MultiChartView({
    super.key,
    required this.chartTitle,
    required this.chartConfig,
    required this.analysisRequest,
    required this.results,
    required this.chartHeight,
    this.showCrosshair = true,
    this.prefixDomain = 20,// 20 days before visualize a result data.
  });

  @override
  State<StatefulWidget> createState() => _MultiChartViewState();
}

class _MultiChartViewState extends State<MultiChartView> {
  late TimeController _chartController;
  CrosshairController? _crosshairController;

  void _initializeControllers() {
    // If you are re-initializing, make sure to dispose the old controller
    // if it's already been created. The 'late' keyword means we can't check for null,
    // so a separate check or a different pattern might be needed if you call this
    // outside of initState/didUpdateWidget. However, in this context,
    // we can assume dispose will be handled correctly.
    _chartController = TimeController(
        periodType: widget.chartConfig.periodType,
        domain: widget.results.getDateTimeDomain(widget.prefixDomain));
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

    // Check if the analysisRequest has changed.
    if (widget.analysisRequest != oldWidget.analysisRequest) {
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
    return Padding(padding: EdgeInsets.all(10),
      child: Column(
        children: [
          for (var chart in widget.chartConfig.multiCharts)
            Expanded(flex: 5, child: _buildChart(chart)),
        ],
      )
    );
  }

  Widget _buildChart(MultiChart chart) {
    return SyncChart(
      controller: _chartController,
      crosshairController: _crosshairController,
      analysisRequest: widget.analysisRequest,
      results: widget.results,
      minFunc: (startDate, endDate) => _getMinValue(chart.mainChart, _chartController.visibleStart, _chartController.visibleEnd),
      maxFunc: (startDate, endDate) => _getMaxPrice(chart.mainChart, _chartController.visibleStart, _chartController.visibleEnd),
      overLayCharts: [
        _showMainChart(chart.mainChart),
        for(var suppChart in chart.overlayCharts)
          _showSupplementChart(suppChart),
        if (widget.showCrosshair)
          OverlayTooltipMarker(overlayType: OverlayType.tooltipMarker, controller: _crosshairController!),
      ],
    );
  }

  OverlayChart _showMainChart(MainChartType chartType) {
    return switch(chartType) {
      MainChartType.candlestickPrice =>
        OverlayCandlestick(data: widget.results.getPriceData(20, _chartController.visibleStart, _chartController.visibleEnd)),
      MainChartType.linePrice =>
        OverlayPriceChart(data: widget.results.getPriceData(20, _chartController.visibleStart, _chartController.visibleEnd)),
      MainChartType.macd => OverlayMacd(data: widget.results.getMacd(MACDType.MACD_12_26)),
      MainChartType.volume => OverlayVolume(data: widget.results.getPriceData(20,  _chartController.visibleStart, _chartController.visibleEnd)),
      MainChartType.rsi => OverlayRsi(data: widget.results.getRsi()),
    };
  }

  OverlayChart _showSupplementChart(SupplementChart chartType) {
    return switch (chartType) {
      SupplementChart.bb =>
        OverlayBellingerBand(
            data: widget.results.getBollingerBand(BollingerBandType.lowerBB, 20),
            lineColor: AppTheme.of(context).indicatorLowerBand ?? Colors.green),
    // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.upperBB, 20),
    //     lineColor: AppTheme.of(context).indicatorUpperBand ?? Colors.orangeAccent),
    // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.middleBB, 20),
    //     lineColor: AppTheme.of(context).indicatorMiddleBand ?? Colors.blueAccent),
      SupplementChart.deathCross =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SupplementChart.goldenCross =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SupplementChart.ema =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SupplementChart.emaSignal =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SupplementChart.obv =>
        OverlayOBV(data: widget.results.getPriceData(20, _chartController.visibleStart, _chartController.visibleEnd)),
      SupplementChart.sma =>
        OverlayMovingAverage(data: widget.results.getSMA(20))
    };
  }

  double _getMaxPrice(MainChartType chartType, DateTime? startDate, DateTime? endDate) {
    return switch (chartType) {
      MainChartType.candlestickPrice => widget.results.getMaxPrice(startDate, endDate),
      MainChartType.linePrice => widget.results.getMaxPrice(startDate, endDate),
      MainChartType.macd => widget.results.getMaxMACD(MACDType.MACD_12_26, startDate, endDate),
      MainChartType.volume => widget.results.getMaxVolume(startDate, endDate),
      MainChartType.rsi => widget.results.getMaxRsi(startDate, endDate)
    };
  }

  double _getMinValue(MainChartType chartType, DateTime? startDate, DateTime? endDate) {
    return switch (chartType) {
      MainChartType.candlestickPrice => widget.results.getMinPrice(startDate, endDate),
      MainChartType.linePrice => widget.results.getMinPrice(startDate, endDate),
      MainChartType.macd => widget.results.getMinMACD(MACDType.MACD_12_26, startDate, endDate),
      MainChartType.volume => widget.results.getMinVolume(startDate, endDate),
      MainChartType.rsi => widget.results.getMinRsi(startDate, endDate)
    };
  }
}
