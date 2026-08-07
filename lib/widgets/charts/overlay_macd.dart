import 'dart:math';
import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/chart_style.dart';
import '../../model/results/indicator/macd_result.dart';

enum _OverlayType {
  signal,
  indicatorValue,
}

class OverlayMacd extends OverlayChart {
  final List<MovingAverageConvergenceDivergence> data;
  final Map<String, Color> macdColors;
  final double lineWidth;
  final double barWidth;

  OverlayMacd({
    super.overlayType = OverlayType.macd,
    super.chartStyle = ChartStyle.line,
    required this.data,
    required this.macdColors,
    this.lineWidth = 1.2,
    this.barWidth = 4.0});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || data.isEmpty) return;

    Size valuesSize = Size(size.width, size.height * 0.75);
    if (macdColors.containsKey(MacdParam.signal.name)) {
      _paintCurve(ctx, canvas, valuesSize, macdColors[MacdParam.signal.name]!, _OverlayType.signal);
    }
    if (macdColors.containsKey(MacdParam.macd.name)) {
      _paintCurve(ctx, canvas, size, macdColors[MacdParam.macd.name]!, _OverlayType.indicatorValue);
    }
    if(macdColors.containsKey(MacdParam.histUp.name) && macdColors.containsKey(MacdParam.histDown.name)) {
      Size histogramSize = Size(size.width, size.height * 0.25);
      _paintHistogram(ctx, canvas, histogramSize);
    }
  }

  void _paintCurve(OverlayContext ctx, Canvas canvas, Size size, Color lineColor, _OverlayType type) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final visibleData = data.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    final minValue = switch(type) {
      _OverlayType.signal => visibleData.map((p) => p.signal ?? double.infinity).reduce(min),
      _OverlayType.indicatorValue => visibleData.map((p) => p.macd ?? double.infinity).reduce(min),
    };
    final maxValue = switch(type) {
      _OverlayType.signal => visibleData.map((p) => p.signal ?? -double.infinity).reduce(max),
      _OverlayType.indicatorValue => visibleData.map((p) => p.macd ?? -double.infinity).reduce(max),
    };

    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var elem in visibleData) {
      final val = (type == _OverlayType.signal ? elem.signal : elem.macd) ?? 0.0;
      final x = ctx.dateToPos(elem.dateTime, size);
      final y = ctx.indicatorToPos(val, size.height, minValue, maxValue);
      
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _paintHistogram(OverlayContext ctx, Canvas canvas, Size size) {
    final painHistUp = Paint()
      ..color = macdColors[MacdParam.histUp.name] ?? Colors.greenAccent
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final painHistDown = Paint()
      ..color = macdColors[MacdParam.histDown.name] ?? Colors.redAccent
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final visibleData = data.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    double maxHistAbs = visibleData.map((e) => e.hist?.abs() ?? 0.0).reduce(max);
    if (maxHistAbs == 0) return;

    final chartBottom = size.height * 0.75; // The absolute bottom of the canvas
    final histAreaHeight = size.height;  // This is totalHeight * 0.25
    final zeroY = chartBottom + (histAreaHeight / 2); // Center of the 25% area

    for (final macd in visibleData) {
      final x = ctx.dateToPos(macd.dateTime, size);
      final val = macd.hist ?? 0.0;
      final scaledHeight = (val / maxHistAbs) * (histAreaHeight / 2);
      final yTarget = zeroY - scaledHeight;
      canvas.drawLine(Offset(x, zeroY), Offset(x, yTarget), val >= 0 ? painHistUp : painHistDown);
    }
  }
}
