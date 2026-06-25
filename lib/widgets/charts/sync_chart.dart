import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/axis_label.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:invest_agent/utils/chart_utils.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';
import 'package:invest_agent/widgets/charts/painters/chart_painter.dart';
import 'package:invest_agent/widgets/charts/painters/side_axis_painter.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';
import 'package:invest_agent/widgets/charts/controllers/crosshair_controller.dart';
import 'package:invest_agent/widgets/utils/tooltip_overlay.dart';
import 'painters/bottom_axis_painter.dart';

class SyncChart extends ConsumerStatefulWidget {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final List<OverlayChart> overLayCharts;
  final double Function(DateTime? startDate, DateTime? endDate) minFunc;
  final double Function(DateTime? startDate, DateTime? endDate) maxFunc;
  const SyncChart({super.key, required this.controller, this.crosshairController,
    this.overLayCharts = const[],
    required this.minFunc, required this.maxFunc,
    required ChartConfig mainChartConfig});

  @override
  ConsumerState<SyncChart> createState() => _SyncChartState();
}

class _SyncChartState extends ConsumerState<SyncChart> {

  @override
  Widget build(BuildContext context) {
    const sideLabelsWidth = 60.0;
    const bottomLabelsHeight = 48.0;
    DateTimeLabel? bottomLabel;
    ValueLabel? valueLabel;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, widget.crosshairController]),
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints){
          final datetimePerPixel = widget.controller.visibleSpan.inMilliseconds / constraints.maxWidth;
          Size chartSpace = Size(constraints.maxWidth - sideLabelsWidth, constraints.maxHeight - bottomLabelsHeight);
          final box = context.findRenderObject() as RenderBox;

          return Listener( // Wrap with a Listener
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final scrollDelta = pointerSignal.scrollDelta.dy;
                if (scrollDelta == 0.0) return;

                // Determine zoom factor (tweak the 0.1 value for sensitivity)
                final scaleFactor = 1 - scrollDelta * 0.001;

                // Get the cursor position to zoom towards it
                final localPos = box.globalToLocal(pointerSignal.position);
                final anchorTime = posToDate(localPos.dx, widget.controller.visibleStart, widget.controller.visibleEnd, chartSpace.width);
                widget.controller.zoom(scaleFactor, anchorTime);
              }
            },
            onPointerHover: (pointerSignal) {
              final local = pointerSignal.localPosition;
              final currTime = posToDate(local.dx, widget.controller.visibleStart, widget.controller.visibleEnd, chartSpace.width);
              final nearest = _findNearestValue(widget.controller.visibleStart, currTime, chartSpace.width, chartSpace.height);
              widget.crosshairController?.update(nearest);
              if(nearest != null) {
                bottomLabel = DateTimeLabel(time: nearest.time, position: Offset(0.0, chartSpace.height));
                if (nearest.data.isNotEmpty) {
                  valueLabel = ValueLabel(value: nearest.data.first.value!,
                      position: nearest.position);
                }
              }
            },
            child: GestureDetector(
              onScaleStart: (_) {},
              onScaleUpdate: (details) {
                widget.crosshairController?.clear();
                if ((details.scale - 1.0).abs() > 0.02) {
                  final localPos = details.focalPoint;
                  final local = box.globalToLocal(localPos);
                  final anchorTime = posToDate(local.dx, widget.controller.visibleStart, widget.controller.visibleEnd, chartSpace.width);
                  widget.controller.zoom(details.scale, anchorTime);
                }
                else {
                  if (chartSpace.width <= 0) return;
                  final local = details.focalPointDelta;
                  widget.controller.pan(Duration(milliseconds: (-local.dx * datetimePerPixel).round()));
                }
              },
              // onTapDown: widget.crosshairController == null ? null : (details) {
              //   final local = box.globalToLocal(details.globalPosition);
              //   final currTime = _posToDate(local.dx, width, widget.controller.visibleStart, widget.controller.visibleEnd);
              //   final nearest = _findNearestValue(currTime, width, constraints.maxHeight);
              //   widget.crosshairController?.update(nearest);
              // },
              // onTapUp: (_) => widget.crosshairController?.clear(),
              child:  Stack(
                children: [
                  Column(
                      children: [
                        Expanded(child: Row(children: [
                          // Main chart
                          Expanded(child: CustomPaint(
                            size: Size(chartSpace.width, chartSpace.height),
                              painter: ChartPainter(
                                controller: widget.controller,
                                overlays: widget.overLayCharts,
                                widthSideLabels: sideLabelsWidth
                              ),
                            )
                          ),
                          // Side label
                          SizedBox(width: sideLabelsWidth,
                              child: CustomPaint(
                                size: Size(sideLabelsWidth, chartSpace.height),
                                painter: SideAxisPainter(controller: widget.controller,
                                    minValue: widget.minFunc,
                                    maxValue: widget.maxFunc,
                                    highLightLabels: [?valueLabel]
                                )
                              )
                          )
                        ]),
                        ),
                        // Bottom axis char label
                        SizedBox(width: chartSpace.width,  height: bottomLabelsHeight,
                            child: CustomPaint(
                                size: Size(chartSpace.width, bottomLabelsHeight),
                                painter: BottomAxisPainter(
                                    startDate: widget.controller.visibleStart,
                                    endDate: widget.controller.visibleEnd,
                                    highLightLabels: [?bottomLabel])
                            )
                        )
                      ]
                  ),
                  if (widget.crosshairController != null)
                    TooltipOverlay(viewport: chartSpace, tooltipController: widget.crosshairController!),
                ],
              )
            )
          );
        });
      },
    );
  }

  TooltipData? _findNearestValue(DateTime startDate, DateTime? currTime, double width, double height) {
    if (currTime == null) return null;

    // TODO: find nearest value in the chart
    // List<TooltipItem> items = [];
    // double? nearestPrimaryValue;
    // DateTime? nearestDatetime;
    // int nearestIndex = -1;
    //
    // try {
    //   for (final overlayChart in widget.overLayCharts) {
    //     final data = switch(overlayChart.overlayType) {
    //       OverlayType.bellingerBands =>
    //       (overlayChart as OverlayBellingerBand).data,
    //       OverlayType.macd => (overlayChart as OverlayMacd).data,
    //       OverlayType.movingAverage =>
    //       (overlayChart as OverlayMovingAverage).data,
    //       OverlayType.obv => null,
    //       OverlayType.pattern => null,
    //       OverlayType.priceCandles => (overlayChart as OverlayCandlestick).data,
    //       OverlayType.priceLine => (overlayChart as OverlayPriceChart).data.priceData,
    //       OverlayType.rsi => (overlayChart as OverlayRsi).data,
    //       OverlayType.signal => null,
    //       OverlayType.volume => (overlayChart as OverlayVolume).data,
    //       OverlayType.tooltipMarker => null,
    //     };
    //     if (data == null) continue;
    //
    //     if (nearestIndex == -1) {
    //       nearestIndex = findNearestIndex(currTime, data);
    //       nearestDatetime = data[nearestIndex].dateTime;
    //     }
    //     final snappedItem = data[nearestIndex];
    //     final toolTipItem = switch(overlayChart.overlayType) {
    //       OverlayType.bellingerBands =>
    //           TooltipItem(
    //               overlayType: OverlayType.bellingerBands,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as BellingerBandEntry).stdValue),
    //       OverlayType.macd =>
    //           TooltipItem(
    //               overlayType: OverlayType.macd,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as MACD).macd,
    //               extras: {
    //                 "signal": snappedItem.signal,
    //                 "hist": snappedItem.hist
    //               }
    //           ),
    //       OverlayType.movingAverage =>
    //           TooltipItem(
    //             overlayType: OverlayType.movingAverage,
    //             time: snappedItem.dateTime,
    //             value: (snappedItem as SimpleMovingAverage).rollingMean,
    //           ),
    //       OverlayType.obv => null,
    //       OverlayType.pattern => null,
    //       OverlayType.priceCandles =>
    //           TooltipItem(
    //               overlayType: OverlayType.priceCandles,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as CandleStickItem).closePrice,
    //               extras: {
    //                 "open": snappedItem.openPrice ?? 0.0,
    //                 "high": snappedItem.highPrice ?? 0.0,
    //                 "low": snappedItem.lowPrice ?? 0.0,
    //               }),
    //       OverlayType.priceLine =>
    //           TooltipItem(
    //               overlayType: OverlayType.priceLine,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as IndexPriceItem).closePrice,
    //               extras: {
    //                 "open": snappedItem.openPrice,
    //                 "high": snappedItem.highPrice,
    //                 "low": snappedItem.lowPrice,
    //               }
    //           ),
    //       OverlayType.rsi =>
    //           TooltipItem(
    //               overlayType: OverlayType.rsi,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as RSI).rsi),
    //       OverlayType.signal => null,
    //       OverlayType.volume =>
    //           TooltipItem(
    //               overlayType: OverlayType.volume,
    //               time: snappedItem.dateTime,
    //               value: (snappedItem as IndexPriceItem).volume),
    //       OverlayType.tooltipMarker => throw UnimplementedError(),
    //     };
    //
    //     if (toolTipItem != null) {
    //       if (toolTipItem.overlayType == OverlayType.priceCandles ||
    //           toolTipItem.overlayType == OverlayType.priceLine ||
    //           toolTipItem.overlayType == OverlayType.volume) {
    //         nearestPrimaryValue = toolTipItem.value;
    //       }
    //       items.add(toolTipItem);
    //     }
    //   }
    //
    //   if (nearestPrimaryValue != null && nearestDatetime != null) {
    //     final x = dateToPos(nearestDatetime, widget.controller.visibleStart,
    //         widget.controller.visibleEnd, width);
    //     final y = valueToPos(currValue: nearestPrimaryValue,
    //         min: widget.indicatorResult.minValue,
    //         max: widget.indicatorResult.maxValue,
    //         height: height);
    //     return TooltipData(position: Offset(x, y), time: currTime, data: items);
    //   }
    // }
    // catch(r) {
    //   log(r.toString());
    // }
    return null;
  }
}