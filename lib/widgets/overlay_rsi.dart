import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';

import 'overlay_chart.dart';

class OverlayRsi extends OverlayChart {
  final List<RSI> data;
  final Color lineColor;
  final double lineWidth;

  OverlayRsi({
    super.overlayType = OverlayType.rsi,
    required this.data,
    this.lineColor = Colors.blue,
    this.lineWidth = 1.0,
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0) return;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
      (rsi) => rsi.dateTime.isAfter(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final minValue = data
        .skip(firstVisibleIndex)
        .reduce((curr, next) => curr.rsi <= next.rsi ? curr : next)
        .rsi;
    final maxValue = data
        .skip(firstVisibleIndex)
        .reduce((curr, next) => curr.rsi > next.rsi ? curr : next)
        .rsi;
    if (minValue == 0.0 || maxValue == 0.0) return;

    final path = Path();
    path.moveTo(
      ctx.dateToPos(data[firstVisibleIndex].dateTime, size),
      ctx.indicatorToPos(
        data[firstVisibleIndex].rsi,
        minValue,
        maxValue,
        size.height,
      ),
    );
    for (var value in data.skip(firstVisibleIndex)) {
      if (value.dateTime.isBefore(ctx.startDate) ||
          value.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final Offset offset = Offset(
        ctx.dateToPos(value.dateTime, size),
        ctx.indicatorToPos(value.rsi, minValue, maxValue, size.height),
      );
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }
}
