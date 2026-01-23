import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';

enum _OverlayType {
  signal,
  indicatorValue,
}

class OverlayMacd extends OverlayChart {
  final List<MACD> macdData;
  final Color signalColor;
  final Color macdColor;
  final Color upColor;
  final Color downColor;
  final double lineWidth;
  final double barWidth;

  OverlayMacd({required this.macdData,
    this.signalColor = Colors.orangeAccent,
    this.macdColor = Colors.blueAccent,
    this.upColor = Colors.greenAccent,
    this.downColor = Colors.redAccent,
    this.lineWidth = 1.2,
    this.barWidth = 4.0});
  
  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0) return;

    Size valuesSize = Size(size.width, size.height * 0.66);
    _paintCurve(ctx, canvas, valuesSize, signalColor, _OverlayType.signal);
    _paintCurve(ctx, canvas, size, macdColor, _OverlayType.indicatorValue);
    Size histogramSize = Size(size.width, size.height * 0.33);
    _paintHistogram(ctx, canvas, histogramSize);
  }

  void _paintCurve(OverlayContext ctx, Canvas canvas, Size size, Color lineColor, _OverlayType type) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = macdData.indexWhere(
            (elem) => elem.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final path = Path();
    final firstVal = switch(type) {
      _OverlayType.signal => macdData[firstVisibleIndex].signal,
      _OverlayType.indicatorValue => macdData[firstVisibleIndex].macd,
    };

    path.moveTo(
        ctx.dateToPos(macdData[firstVisibleIndex].dateTime, size),
        ctx.valueToPos(firstVal, size));
    for (var elem in macdData.skip(firstVisibleIndex)) {
      if (elem.dateTime.isBefore(ctx.startDate) || elem.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final val = switch(type) {
        _OverlayType.signal => elem.signal,
        _OverlayType.indicatorValue => elem.macd,
      };
      final Offset offset = Offset(ctx.dateToPos(elem.dateTime, size),
          ctx.valueToPos(val, size));
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _paintHistogram(OverlayContext ctx, Canvas canvas, Size size) {
    final painHistUp = Paint()
      ..color = upColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final painHistDown = Paint()
      ..color = downColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    double maxHistAbs = 0;
    for (final  macd in macdData) {
      if (macd.dateTime.isBefore(ctx.startDate) || macd.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      maxHistAbs = max(maxHistAbs, macd.hist.abs());
    }
    if (maxHistAbs == 0) return;

    // Zero Line
    final halfHeight = size.height * 0.5;
    final zeroY = halfHeight;
    for (final macd in macdData) {
      if (macd.dateTime.isBefore(ctx.startDate) || macd.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final x = ctx.dateToPos(macd.dateTime, size);
      final hist = (macd.hist / maxHistAbs) * halfHeight;
      final yTop = zeroY - hist;
      final yBottom = zeroY;

      canvas.drawLine(Offset(x, yBottom), Offset(x, yTop), macd.hist >= 0 ? painHistUp : painHistDown);
    }
  }
}