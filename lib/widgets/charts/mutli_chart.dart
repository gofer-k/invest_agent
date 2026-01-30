import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/charts/sync_chart.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import 'controllers/crosshair_controller.dart';
import 'overlay_chart.dart';
import 'overlay_price_chart.dart';
import 'overlay_tooltip_marker.dart';

class MultiChartView extends StatefulWidget {
  final List<String> chartTitle;
  final AnalysisRequest analysisRequest;
  final AnalysisRespond results;
  final double chartHeight;
  final bool showCrosshair;
  final int prefixDomain;

  const MultiChartView({
    super.key,
    required this.chartTitle,
    required this.analysisRequest,
    required this.results,
    required this.chartHeight,
    this.showCrosshair = true,
    this.prefixDomain = 20, // 20 days before visualize a result data.
  });

  @override
  State<StatefulWidget> createState() => _MultiChartViewState();
}

class _MultiChartViewState extends State<MultiChartView> {
  late final TimeController _chartController;
  late final CrosshairController? _crosshairController;
  @override
  void initState() {
    super.initState();

    _chartController = TimeController(
      periodType: widget.analysisRequest.periodType,
      domain: widget.results.getDateTimeDomain(widget.prefixDomain));
    if (widget.showCrosshair) {
      _crosshairController = CrosshairController();
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
          Expanded(flex: 5,
             child: SyncChart(controller: _chartController,
                crosshairController: _crosshairController,
                analysisRequest: widget.analysisRequest,
                results: widget.results,
                minFunc: (startDate, endDate) => widget.results.getMinPrice(_chartController.visibleStart, _chartController.visibleEnd),
                maxFunc: (startDate, endDate) => widget.results.getMaxPrice(_chartController.visibleStart, _chartController.visibleEnd),
                overLayCharts: [
                  OverlayPriceChart(data: widget.results.getPriceData(20)),
                  if (widget.showCrosshair)
                    OverlayTooltipMarker(overlayType: OverlayType.tooltipMarker, controller: _crosshairController!),
                  // OverlayCandlestick(data: widget.results.getPriceData(20)),
                  // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.lowerBB, 20),
                  //     lineColor: AppTheme.of(context).indicatorLowerBand ?? Colors.green),
                  // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.upperBB, 20),
                  //     lineColor: AppTheme.of(context).indicatorUpperBand ?? Colors.orangeAccent),
                  // OverlayBellingerBand(band: widget.results.getBollingerBand(BollingerBandType.middleBB, 20),
                  //     lineColor: AppTheme.of(context).indicatorMiddleBand ?? Colors.blueAccent),
                  // OverlayMovingAverage(data: widget.results.getSMA(20))
                  // OverlayOBV(priceData: widget.results.getPriceData(20))
                ],),
          ),
          // Expanded(flex: 1,
          //   child: SyncChart(controller: _chartController,
          //       crosshairController: _crosshairController,
          //       analysisRequest: widget.analysisRequest,
          //       results: widget.results,
          //       minFunc: () => widget.results.getMinVolume(),
          //       maxFunc: () => widget.results.getMaxVolume(),
          //       overLayCharts: [
          //         OverlayVolume(priceData: widget.results.getPriceData(20))
          //       ],
          //   ),
          // ),
          // Expanded(flex: 1,
          //   child: SyncChart(controller: _chartController,
          //     crosshairController: _crosshairController,
          //     analysisRequest: widget.analysisRequest,
          //     results: widget.results,
          //     minFunc: () => widget.results.getMinMACD(MACDType.MACD_12_26),
          //     maxFunc: () => widget.results.getMaxMACD(MACDType.MACD_12_26),
          //     overLayCharts: [
          //       OverlayMacd(macdData: widget.results.getMacd(MACDType.MACD_12_26))
          //     ],
          //   ),
          // ),
          // Expanded(flex: 1,
          //   child: SyncChart(controller: _chartController,
          //     crosshairController: _crosshairController,
          //     analysisRequest: widget.analysisRequest,
          //     results: widget.results,
          //     minFunc: () => widget.results.getMinRsi(),
          //     maxFunc: () => widget.results.getMaxRsi(),
          //     overLayCharts: [ OverlayRsi(rsi: widget.results.getRsi()) ],
          //   ),
          // ),
        ],
      )
    );
  }
}
