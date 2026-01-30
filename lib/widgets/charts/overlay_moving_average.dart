import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';
import '../../model/analysis_respond.dart';

class OverlayMovingAverage extends OverlayChart {
  final List<SimpleMovingAverage> data;
  final Color lineColor;
  final double strokeWidth;

  OverlayMovingAverage({super.overlayType = OverlayType.movingAverage,
    required this.data,
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

    final minValue = data.skip(firstVisibleIndex).reduce((curr, next) => curr.rollingMean! <= next.rollingMean! ? curr : next).rollingMean ?? 0.0;
    final maxValue = data.skip(firstVisibleIndex).reduce((curr, next) => curr.rollingMean! > next.rollingMean! ? curr : next).rollingMean ?? 0.0;

    final path = Path();
    path.moveTo(
        ctx.dateToPos(data[firstVisibleIndex].dateTime, size),
        ctx.indicatorToPos(data[firstVisibleIndex].rollingMean ?? 0.0, minValue, maxValue, size.height));
    for (var ma in data.skip(firstVisibleIndex)) {
      if (ma.dateTime.isBefore(ctx.startDate) || ma.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final Offset offset = Offset(ctx.dateToPos(ma.dateTime, size),
          ctx.indicatorToPos(ma.rollingMean ?? 0.0, minValue, maxValue, size.height));
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }
}