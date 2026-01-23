import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';
import '../model/analysis_respond.dart';

class OverlayMovingAverage extends OverlayChart {
  final List<SimpleMovingAverage> data;
  final Color lineColor;
  final double strokeWidth;

  OverlayMovingAverage({required this.data,
    this.lineColor = Colors.blueAccent,
    this.strokeWidth = 1.5});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
            (ma) => ma.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final path = Path();
    path.moveTo(
        ctx.dateToPos(data[firstVisibleIndex].dateTime, size),
        ctx.valueToPos(data[firstVisibleIndex].rollingMean ?? 0.0, size));
    for (var ma in data.skip(firstVisibleIndex)) {
      if (ma.dateTime.isBefore(ctx.startDate) || ma.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final Offset offset = Offset(ctx.dateToPos(ma.dateTime, size),
          ctx.valueToPos(ma.rollingMean ?? 0.0, size));
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }
}