import 'package:flutter/material.dart';
import 'package:invest_agent/model/results/indicator/indicator_result.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/chart_style.dart';
import '../../model/results/indicator/ema_result.dart';

class OverlayExponentialMovingAverage extends OverlayChart {
  final List<ExponentialMovingAverage> _data;
  final Map<String, Color> emaColors;
  final double strokeWidth;

  OverlayExponentialMovingAverage({
    super.overlayType = OverlayType.movingAverage,
    super.chartStyle = ChartStyle.line,
    required List<ExponentialMovingAverage> data,
    required this.emaColors,
    this.strokeWidth = 1.5,
  }) : _data = data;

  @override
  List<BaseIndicatorValue> get data => _data;

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || _data.isEmpty) return;

    final paint = Paint()
      ..color = emaColors["chart"] ?? Colors.blue
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = _data.indexWhere(
      (ma) => ma.dateTime.isAfter(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return;

    final visibleData = _data.skip(firstVisibleIndex).toList();
    if (visibleData.isEmpty) return;

    final minValue =
        visibleData
            .reduce(
              (curr, next) =>
                  (curr.maValue ?? 0.0) < (next.maValue ?? 0.0) ? curr : next,
            )
            .maValue ??
        0.0;
    final maxValue =
        visibleData
            .reduce(
              (curr, next) =>
                  (curr.maValue ?? 0.0) > (next.maValue ?? 0.0) ? curr : next,
            )
            .maValue ??
        0.0;

    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var ma in visibleData) {
      if (ma.dateTime.isAfter(ctx.endDate)) break;

      final x = ctx.dateToPos(ma.dateTime, size);
      final y = ctx.indicatorToPos(
        ma.maValue ?? 0.0,
        size.height,
        minValue,
        maxValue,
      );

      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }
}
