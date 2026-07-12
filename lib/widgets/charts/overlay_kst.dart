import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/results/kst_result.dart';

class OverlayKnowSureThing extends OverlayChart {
  final List<Kst> points;
  final Map<String, Color> kstColors;
  final double lineWidth;

  OverlayKnowSureThing({super.overlayType = OverlayType.kst,
    required this.points,
    required this.kstColors,
    this.lineWidth = 1.5});

  void _paintCurve(OverlayContext ctx, Canvas canvas, Size size,
      Color lineColor, {required bool isKst, required double maxValue, required double minValue}) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final visibleData = points.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    final path = Path();
    bool started = false;

    for (var elem in visibleData) {
      final val = (isKst ? elem.kst : elem.signal) ?? 0.0;
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

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || points.isEmpty) return;

    final visibleData = points.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    final (minKst, minSignal) =
      (visibleData.map((p) => p.kst ?? double.infinity).reduce(min),
      visibleData.map((p) => p.signal ?? double.infinity).reduce(min));

    final (maxKst, maxSignal) =
      (visibleData.map((p) => p.kst ?? double.infinity).reduce(max),
      visibleData.map((p) => p.signal ?? double.infinity).reduce(max));

    final maxValue = min(maxKst, maxSignal);
    final minValue = max(minKst, minSignal);

    if (minValue == maxValue) return;

    if (kstColors.containsKey(KstParam.kstChart.name)) {
      _paintCurve(ctx, canvas, size,
         kstColors[KstParam.kstChart.name] ?? Colors.blue,
         isKst: true,
         maxValue: maxValue, minValue: minValue);
    }
    if (kstColors.containsKey(KstParam.signalChart.name)) {
      _paintCurve(ctx, canvas, size,
        kstColors[KstParam.signalChart.name] ?? Colors.orange,
        isKst: false,
        maxValue: maxValue, minValue: minValue);
    }
    if (kstColors.containsKey(KstParam.zeroLevel.name)) {
      OverlayChart.drawLevelLine(canvas, size, ctx,
        lineColor: kstColors[KstParam.zeroLevel.name] ?? Colors.grey,
        lineWidth: lineWidth,
        level: 0.0, maxBound: maxValue, minBound: minValue);
    }
  }
}
