import 'package:flutter/material.dart';
import 'package:invest_agent/model/results/analysis_respond.dart';

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
    if (size.width <= 0 || data.isEmpty) return;
    
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
      (rsi) => rsi.dateTime.isAfter(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final visibleData = data.skip(firstVisibleIndex).toList();
    if (visibleData.isEmpty) return;

    final minValue = visibleData
        .reduce((curr, next) => curr.rsi <= next.rsi ? curr : next)
        .rsi;
    final maxValue = visibleData
        .reduce((curr, next) => curr.rsi > next.rsi ? curr : next)
        .rsi;
    
    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var value in visibleData) {
      if (value.dateTime.isAfter(ctx.endDate)) break;
      
      final x = ctx.dateToPos(value.dateTime, size);
      final y = ctx.indicatorToPos(value.rsi, size.height, minValue, maxValue);
      
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
