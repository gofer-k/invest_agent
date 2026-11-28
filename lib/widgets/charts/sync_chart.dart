import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/model/axis_label.dart';
import 'package:invest_agent/model/multi_chart_schema.dart';
import 'package:invest_agent/model/results/indicator/kst_result.dart';
import 'package:invest_agent/model/results/indicator/price_result.dart';
import 'package:invest_agent/model/results/indicator/rsi_result.dart';
import 'package:invest_agent/utils/chart_utils.dart';
import 'package:invest_agent/widgets/charts/controllers/crosshair_controller.dart';
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';
import 'package:invest_agent/widgets/charts/painters/chart_painter.dart';
import 'package:invest_agent/widgets/charts/painters/side_axis_painter.dart';
import 'package:invest_agent/widgets/utils/tooltip_overlay.dart';

import '../../model/results/indicator/bollinger_bands_result.dart';
import '../../model/results/indicator/ema_result.dart';
import '../../model/results/indicator/macd_result.dart';
import '../../model/results/indicator/roc_result.dart';
import '../../model/results/indicator/sma_result.dart';
import 'painters/bottom_axis_painter.dart';

class SyncChart extends ConsumerStatefulWidget {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final List<OverlayChart> overLayCharts;
  final double Function(DateTime? startDate, DateTime? endDate) minFunc;
  final double Function(DateTime? startDate, DateTime? endDate) maxFunc;

  const SyncChart({
    super.key,
    required this.controller,
    this.crosshairController,
    this.overLayCharts = const [],
    required this.minFunc,
    required this.maxFunc,
    required ChartConfig mainChartConfig,
  });

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
      animation: Listenable.merge([
        widget.controller,
        widget.crosshairController,
      ]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final datetimePerPixel =
                widget.controller.visibleSpan.inMilliseconds /
                constraints.maxWidth;
            Size chartSpace = Size(
              constraints.maxWidth - sideLabelsWidth,
              constraints.maxHeight - bottomLabelsHeight,
            );
            final box = context.findRenderObject() as RenderBox;

            return Listener(
              // Wrap with a Listener
              onPointerSignal: (pointerSignal) =>
                  _handleScrollSignal(pointerSignal, box, chartSpace),
              onPointerHover: (pointerSignal) =>
                  _handleHoverSignal(pointerSignal, chartSpace),
              child: GestureDetector(
                onScaleStart: (_) {},
                onScaleUpdate: (details) => _handleScaleGesture(
                  details,
                  datetimePerPixel,
                  box,
                  chartSpace,
                ),
                onTapDown: widget.crosshairController == null
                    ? null
                    : (details) => _handleTapDownGesture(
                        details,
                        constraints.maxHeight,
                        box,
                        chartSpace,
                      ),
                onTapUp: (_) => widget.crosshairController?.clear(),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Main chart
                              Expanded(
                                child: CustomPaint(
                                  size: Size(
                                    chartSpace.width,
                                    chartSpace.height,
                                  ),
                                  painter: ChartPainter(
                                    controller: widget.controller,
                                    overlays: widget.overLayCharts,
                                    widthSideLabels: sideLabelsWidth,
                                  ),
                                ),
                              ),
                              // Side label
                              SizedBox(
                                width: sideLabelsWidth,
                                child: CustomPaint(
                                  size: Size(
                                    sideLabelsWidth,
                                    chartSpace.height,
                                  ),
                                  painter: SideAxisPainter(
                                    controller: widget.controller,
                                    minValue: widget.minFunc,
                                    maxValue: widget.maxFunc,
                                    highLightLabels: [?valueLabel],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom axis char label
                        SizedBox(
                          width: chartSpace.width,
                          height: bottomLabelsHeight,
                          child: CustomPaint(
                            size: Size(chartSpace.width, bottomLabelsHeight),
                            painter: BottomAxisPainter(
                              startDate: widget.controller.visibleStart,
                              endDate: widget.controller.visibleEnd,
                              highLightLabels: [?bottomLabel],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.crosshairController != null)
                      TooltipOverlay(
                        viewport: chartSpace,
                        tooltipController: widget.crosshairController!,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleScrollSignal(
    PointerSignalEvent signal,
    RenderBox contextSpace,
    Size chartSpace,
  ) {
    if (signal is PointerScrollEvent) {
      final scrollDelta = signal.scrollDelta.dy;
      if (scrollDelta == 0.0) return;

      // Determine zoom factor (tweak the 0.1 value for sensitivity)
      final scaleFactor = 1 - scrollDelta * 0.001;

      // Get the cursor position to zoom towards it
      final localPos = contextSpace.globalToLocal(signal.position);
      final anchorTime = posToDate(
        localPos.dx,
        widget.controller.visibleStart,
        widget.controller.visibleEnd,
        chartSpace.width,
      );
      widget.controller.zoom(scaleFactor, anchorTime);
    }
  }

  (DateTimeLabel?, ValueLabel?) _handleHoverSignal(
    PointerHoverEvent signal,
    Size chartSpace,
  ) {
    DateTimeLabel? timeLabel;
    ValueLabel? valueLabel;

    final local = signal.localPosition;
    final currTime = posToDate(
      local.dx,
      widget.controller.visibleStart,
      widget.controller.visibleEnd,
      chartSpace.width,
    );
    final nearest = _findNearestValue(
      widget.controller.visibleStart,
      currTime,
      chartSpace.width,
      chartSpace.height,
    );
    widget.crosshairController?.update(nearest);
    if (nearest != null) {
      timeLabel = DateTimeLabel(
        time: nearest.time,
        position: Offset(0.0, chartSpace.height),
      );
      if (nearest.data.isNotEmpty) {
        valueLabel = ValueLabel(
          value: nearest.data.first.value!,
          position: nearest.position,
        );
      }
    }
    return (timeLabel, valueLabel);
  }

  void _handleScaleGesture(
    ScaleUpdateDetails scaleDetails,
    double timeStampPerPixel,
    RenderBox contextSpace,
    Size chartSpace,
  ) {
    widget.crosshairController?.clear();
    if ((scaleDetails.scale - 1.0).abs() > 0.02) {
      final localPos = scaleDetails.focalPoint;
      final local = contextSpace.globalToLocal(localPos);
      final anchorTime = posToDate(
        local.dx,
        widget.controller.visibleStart,
        widget.controller.visibleEnd,
        chartSpace.width,
      );
      widget.controller.zoom(scaleDetails.scale, anchorTime);
    } else {
      if (chartSpace.width <= 0) return;
      final local = scaleDetails.focalPointDelta;
      widget.controller.pan(
        Duration(milliseconds: (-local.dx * timeStampPerPixel).round()),
      );
    }
  }

  void _handleTapDownGesture(
    TapDownDetails tapDetails,
    double maxHeight,
    RenderBox contextSpace,
    Size chartSpace,
  ) {
    {
      final local = contextSpace.globalToLocal(tapDetails.globalPosition);
      final currTime = posToDate(
        local.dx,
        widget.controller.visibleStart,
        widget.controller.visibleEnd,
        chartSpace.width,
      );
      final nearest = _findNearestValue(
        widget.controller.visibleStart,
        currTime,
        chartSpace.width,
        maxHeight,
      );
      widget.crosshairController?.update(nearest);
    }
  }

  TooltipData? _findNearestValue(
    DateTime startDate,
    DateTime? currTime,
    double width,
    double height,
  ) {
    if (currTime == null) return null;

    // TODO: find nearest value in the chart
    List<TooltipItem> items = [];
    double? nearestPrimaryValue;
    DateTime? nearestDatetime;
    int nearestIndex = -1;

    try {
      for (final overlayChart in widget.overLayCharts) {
        if (overlayChart.data.isEmpty) continue;

        if (nearestIndex == -1) {
          nearestIndex = findNearestIndex(currTime, overlayChart.data);
          nearestDatetime = overlayChart.data[nearestIndex].dateTime;
        }

        final toolTipItem = _buildToolTip(overlayChart, nearestIndex);

        if (toolTipItem != null) {
          if (toolTipItem.overlayType == OverlayType.price ||
              toolTipItem.overlayType == OverlayType.volume) {
            nearestPrimaryValue = toolTipItem.value;
          }
          items.add(toolTipItem);
        }
      }
      if (nearestPrimaryValue != null && nearestDatetime != null) {
        final x = dateToPos(
          nearestDatetime,
          widget.controller.visibleStart,
          widget.controller.visibleEnd,
          width,
        );
        final y = valueToPos(
          currValue: nearestPrimaryValue,
          min: widget.minFunc(
            widget.controller.visibleStart,
            widget.controller.visibleEnd,
          ),
          max: widget.maxFunc(
            widget.controller.visibleStart,
            widget.controller.visibleEnd,
          ),
          height: height,
        );
        return TooltipData(position: Offset(x, y), time: currTime, data: items);
      }
    } catch (r) {
      log(r.toString());
    }
    return null;
  }

  TooltipItem? _buildToolTip(OverlayChart chart, int index) {
    final snappedItem = chart.data[index];

    return switch (chart.overlayType) {
      OverlayType.bollingerBands => TooltipItem(
        overlayType: OverlayType.bollingerBands,
        time: snappedItem.dateTime,
        value: (snappedItem as BollingerBands).medianBB,
      ),
      OverlayType.ema => TooltipItem(
        overlayType: OverlayType.ema,
        time: snappedItem.dateTime,
        value: (snappedItem as ExponentialMovingAverage).maValue,
      ),
      OverlayType.empty => null,
      OverlayType.kst => () {
        final kstPoint = snappedItem as Kst;
        return TooltipItem(
          overlayType: OverlayType.kst,
          time: snappedItem.dateTime,
          value: kstPoint.kst,
          extras: {"signal": kstPoint.signal ?? double.infinity},
        );
      }(),
      OverlayType.macd => () {
        final macdPoint = snappedItem as MovingAverageConvergenceDivergence;
        return TooltipItem(
          overlayType: OverlayType.macd,
          time: snappedItem.dateTime,
          value: macdPoint.macd,
          extras: {
            "signal": macdPoint.signal ?? double.infinity,
            "hist": macdPoint.hist ?? double.infinity,
          },
        );
      }(),
      OverlayType.movingAverage => TooltipItem(
        overlayType: OverlayType.movingAverage,
        time: snappedItem.dateTime,
        value: (snappedItem as SimpleMovingAverage).rollingMean,
      ),
      OverlayType.obv => null,
      OverlayType.pattern => null,
      OverlayType.price => TooltipItem(
        overlayType: OverlayType.price,
        time: snappedItem.dateTime,
        value: (snappedItem as IndexPriceItem).closePrice,
        extras: {
          "open": snappedItem.openPrice,
          "high": snappedItem.highPrice,
          "low": snappedItem.lowPrice,
        },
      ),
      OverlayType.rsi => TooltipItem(
        overlayType: OverlayType.rsi,
        time: snappedItem.dateTime,
        value: (snappedItem as Rsi).rsi,
      ),
      OverlayType.roc => TooltipItem(
        overlayType: OverlayType.rsi,
        time: snappedItem.dateTime,
        value: (snappedItem as Roc).roc,
      ),
      OverlayType.signal => null,
      OverlayType.tooltipMarker => null,
      OverlayType.volume => TooltipItem(
        overlayType: OverlayType.volume,
        time: snappedItem.dateTime,
        value: (snappedItem as IndexPriceItem).volume,
      ),
    };
  }
}
