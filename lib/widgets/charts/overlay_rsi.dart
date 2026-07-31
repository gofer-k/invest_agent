import 'package:flutter/material.dart';
import 'package:invest_agent/model/results/rsi_result.dart';

import '../../model/chart_style.dart';
import 'overlay_chart.dart';

class OverlayRsi extends OverlayChart {
  final List<Rsi> data;
  final double? upperBound;
  final double? lowerBound;
  final double? baseLevel;
  final Map<String, Color> rsiColors;
  final double lineWidth;

  OverlayRsi({
    super.overlayType = OverlayType.rsi,
    super.chartStyle = ChartStyle.line,
    required this.data,
    required this.rsiColors,
    this.lineWidth = 1.0, this.upperBound, this.lowerBound, this.baseLevel,
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || data.isEmpty) return;
    
    final paint = Paint()
      ..color = rsiColors[RsiParam.rsi.name] ?? Colors.blue
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
      (rsi) => rsi.dateTime.isAfter(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final visibleData = data.skip(firstVisibleIndex).toList();
    if (visibleData.isEmpty) return;

    final minValue = visibleData.reduce((curr, next) => (curr.rsi ?? 0.0) < (next.rsi ?? 0.0) ? curr : next).rsi ?? 0.0;
    final maxValue = visibleData.reduce((curr, next) => (curr.rsi ?? 0.0) > (next.rsi ?? 0.0) ? curr : next).rsi ?? 0.0;

    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var value in visibleData) {
      if (value.dateTime.isAfter(ctx.endDate)) break;
      
      final x = ctx.dateToPos(value.dateTime, size);
      final y = ctx.indicatorToPos(value.rsi ?? 0.0, size.height, minValue, maxValue);
      
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    if (lowerBound != null && rsiColors.containsKey(RsiParam.lowerLevel.name)) {
      OverlayChart.drawLevelLine(canvas, size, ctx,
        lineColor: rsiColors[RsiParam.lowerLevel.name]!,
        lineWidth: lineWidth,
        level: lowerBound!, maxBound: maxValue, minBound: minValue);
    }
    if (upperBound != null && rsiColors.containsKey(RsiParam.upperLevel.name)) {
      OverlayChart.drawLevelLine(canvas, size, ctx,
        lineColor: rsiColors[RsiParam.upperLevel.name]!,
        lineWidth: lineWidth,
        level: upperBound!, maxBound: maxValue, minBound: minValue);
    }
    if (baseLevel != null && rsiColors.containsKey(RsiParam.middleLevel.name)) {
      OverlayChart.drawLevelLine(canvas, size, ctx,
        lineColor: rsiColors[RsiParam.middleLevel.name]!,
        lineWidth: lineWidth,
        level: baseLevel!, maxBound: maxValue, minBound: minValue);
    }
  }
}
