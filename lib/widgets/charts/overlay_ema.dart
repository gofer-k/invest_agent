import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/ema_result.dart';

class OverlayExponentialMovingAverage extends OverlayChart {
  final List<ExponentialMovingAverage> data;
  final Color lineColor;
  final double strokeWidth;

  OverlayExponentialMovingAverage({super.overlayType = OverlayType.movingAverage,
    required this.data,
    this.lineColor = Colors.blueAccent,
    this.strokeWidth = 1.5});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
            (ma) => ma.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return;

    final visibleData = data.skip(firstVisibleIndex).toList();
    if (visibleData.isEmpty) return;

    final minValue = visibleData.reduce((curr, next) => (curr.maValue ?? 0.0) <= (next.maValue ?? 0.0) ? curr : next).maValue ?? 0.0;
    final maxValue = visibleData.reduce((curr, next) => (curr.maValue ?? 0.0) > (next.maValue ?? 0.0) ? curr : next).maValue ?? 0.0;

    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var ma in visibleData) {
      if (ma.dateTime.isAfter(ctx.endDate)) break;

      final x = ctx.dateToPos(ma.dateTime, size);
      final y = ctx.indicatorToPos(ma.maValue ?? 0.0, size.height, minValue, maxValue);

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
