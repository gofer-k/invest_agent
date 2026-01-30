import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_request.dart';
import 'package:invest_agent/utils/chart_utils.dart';
import 'package:invest_agent/widgets/charts/overlay_bellinger_band.dart';
import 'package:invest_agent/widgets/charts/overlay_candlestick.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';
import 'package:invest_agent/widgets/charts/painters/chart_painter.dart';
import 'package:invest_agent/widgets/charts/overlay_macd.dart';
import 'package:invest_agent/widgets/charts/overlay_moving_average.dart';
import 'package:invest_agent/widgets/charts/overlay_price_chart.dart';
import 'package:invest_agent/widgets/charts/overlay_rsi.dart';
import 'package:invest_agent/widgets/charts/overlay_volume.dart';
import 'package:invest_agent/widgets/charts/painters/side_axis_painter.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';
import 'package:invest_agent/widgets/charts/controllers/crosshair_controller.dart';
import 'package:invest_agent/widgets/utils/tooltip_overlay.dart';
import '../../model/analysis_respond.dart';
import 'painters/bottom_axis_painter.dart';

class SyncChart extends StatefulWidget {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final AnalysisRequest analysisRequest;
  final AnalysisRespond results;
  final List<OverlayChart> overLayCharts;
  final double Function() minFunc;
  final double Function() maxFunc;
  const SyncChart({super.key, required this.controller, this.crosshairController,
    required this.analysisRequest, required this.results,
    this.overLayCharts = const[], required this.minFunc, required this.maxFunc});

  @override
  State<StatefulWidget> createState() => _SyncChartState();
}

class _SyncChartState extends State<SyncChart> {

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.crosshairController]),
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints){
          final daysPerPixel = widget.controller.visibleSpan.inDays / constraints.maxWidth;
          final width = constraints.maxWidth;
          final box = context.findRenderObject() as RenderBox;
          final widthSideLabels = 60.0;

          return Listener( // Wrap with a Listener
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final scrollDelta = pointerSignal.scrollDelta.dy;
                if (scrollDelta == 0.0) return;

                // Determine zoom factor (tweak the 0.1 value for sensitivity)
                final scaleFactor = 1 - scrollDelta * 0.001;

                // Get the cursor position to zoom towards it
                final localPos = box.globalToLocal(pointerSignal.position);
                final anchorTime = _posToDate(localPos.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                widget.controller.zoom(scaleFactor, anchorTime);
              }
            },
            child: GestureDetector(
              onScaleStart: (_) {},
              onScaleUpdate: (details) {
                widget.crosshairController?.clear();
                if ((details.scale - 1.0).abs() > 0.02) {
                  final localPos = details.focalPoint;
                  final local = box.globalToLocal(localPos);
                  final anchorTime = _posToDate(local.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                  widget.controller.zoom(details.scale, anchorTime);
                }
                else {
                  if (width <= 0) return;
                  final local = details.focalPointDelta;
                  widget.controller.pan(Duration(days: (-local.dx * daysPerPixel).round()));
                }
              },
              onTapDown: widget.crosshairController == null ? null : (details) {
                final local = box.globalToLocal(details.globalPosition);
                final currTime = _posToDate(local.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
                final nearest = _findNearestValue(currTime, width, constraints.maxHeight);
                widget.crosshairController?.update(nearest);
              },
              onTapUp: (_) => widget.crosshairController?.clear(),
              child:  Stack(
                children: [
                  Column(
                      children: [
                        Expanded(child: Row(children: [
                          // Main chart
                          Expanded(child: CustomPaint(
                            size: Size(width, constraints.minHeight),
                              painter: ChartPainter(
                                controller: widget.controller,
                                analysisRequest: widget.analysisRequest,
                                results: widget.results,
                                overlays: widget.overLayCharts,
                                widthSideLabels: widthSideLabels
                              ),
                            )
                          ),
                          // Side label
                          SizedBox(width: widthSideLabels,
                              child: CustomPaint(
                                  size: Size(width, constraints.maxHeight),
                                  painter: SideAxisPainter(minValue: widget.minFunc, maxValue: widget.maxFunc)
                              )
                          )
                        ]),
                        ),
                        // Bottom axis char label
                        SizedBox(width: constraints.maxWidth - widthSideLabels,  height: 48,
                            child: CustomPaint(
                                size: Size(width, 48),
                                painter: BottomAxisPainter(startDate: widget.controller.visibleStart, endDate: widget.controller.visibleEnd)
                            )
                        )
                      ]
                  ),
                  if (widget.crosshairController != null)
                    TooltipOverlay(tooltipController: widget.crosshairController!),
                ],
              )
            )
          );
        });
      },
    );
  }

  DateTime? _posToDate(double pos, double width, DateTime startDate, DateTime endDate) {
    final ratio = (pos / width).clamp(0.0, 1.0);
    final spanDays = endDate.difference(startDate).inDays;
    return startDate.add(Duration(days: (spanDays * ratio).round()));
  }

  TooltipData? _findNearestValue(DateTime? currTime, double width, double height) {
    if (currTime == null) return null;

    List<TooltipItem> items = [];
    double? nearestPrice;
    for (final overlayChart in widget.overLayCharts) {
      final data = switch(overlayChart.overlayType) {
        OverlayType.bellingerBands => (overlayChart as OverlayBellingerBand).data,
        OverlayType.macd => (overlayChart as OverlayMacd).data,
        OverlayType.movingAverage => (overlayChart as OverlayMovingAverage).data,
        OverlayType.obv => null,
        OverlayType.pattern => null,
        OverlayType.priceCandles => (overlayChart as OverlayCandlestick).data,
        OverlayType.priceLine => (overlayChart as OverlayPriceChart).data,
        OverlayType.rsi => (overlayChart as OverlayRsi).data,
        OverlayType.signal => null,
        OverlayType.volume => (overlayChart as OverlayVolume).data,
        // TODO: Handle this case.
        OverlayType.tooltipMarker => null,
      };
      if (data == null) continue;

      var best = data.first;
      int bestDiff = (best.dateTime.difference(currTime)).abs().inDays;
      for (final c in data) {
        final diff = (c.dateTime.difference(currTime)).abs().inDays;
        if (diff < bestDiff) {
          best = c; bestDiff = diff;
        }
      }

      final toolTipItem = switch(overlayChart.overlayType) {
        OverlayType.bellingerBands => TooltipItem(
            overlayType: OverlayType.bellingerBands,
            time: best.dateTime,
            value: (best as BellingerBandEntry).stdValue),
        OverlayType.macd => TooltipItem(
            overlayType: OverlayType.macd,
            time: best.dateTime,
            value: (best as MACD).macd,
            extras: {"signal": (best).signal, "hist": (best).hist}
        ),
        OverlayType.movingAverage => TooltipItem(
          overlayType: OverlayType.movingAverage,
          time: best.dateTime,
          value: (best as SimpleMovingAverage).rollingMean,
        ),
        OverlayType.obv => null,
        OverlayType.pattern => null,
        OverlayType.priceCandles => TooltipItem(
          overlayType: OverlayType.priceCandles,
          time: best.dateTime,
          value: (best as CandleStickItem).closePrice,
          extras: {
            "open": best.openPrice ?? 0.0,
            "high": best.highPrice ?? 0.0,
            "low": best.lowPrice ?? 0.0,
          }),
        OverlayType.priceLine => TooltipItem(
          overlayType: OverlayType.priceLine,
          time: best.dateTime,
          value: (best as PriceData).closePrice,
          extras: {
            "open": (best).openPrice,
            "high": (best).highPrice,
            "low": (best).lowPrice,
          }
        ),
        OverlayType.rsi => TooltipItem(
          overlayType: OverlayType.rsi,
            time: best.dateTime,
            value: (best as RSI).rsi),
        OverlayType.signal => null,
        OverlayType.volume => TooltipItem(
          overlayType: OverlayType.volume,
            time: best.dateTime,
            value: (best as PriceData).volume),
        // TODO: Handle this case.
        OverlayType.tooltipMarker => throw UnimplementedError(),
      };

      if (toolTipItem != null) {
        if (toolTipItem.overlayType == OverlayType.priceCandles || toolTipItem.overlayType == OverlayType.priceLine) {
          nearestPrice = toolTipItem.value;
        }
        items.add(toolTipItem);
      }
    }
    if (nearestPrice != null) {
      final x = dateToPos(currTime, widget.controller.visibleStart, widget.controller.visibleEnd, width);
      final y = valueToPos(currValue: nearestPrice, min: widget.results.minPrice, max: widget.results.maxPrice, height: height);
      return TooltipData(position: Offset(x, y), time: currTime, data: items);
    }
    return null;
  }
}