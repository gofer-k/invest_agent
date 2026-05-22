import 'dart:math';
import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

enum _OverlayType {
  signal,
  indicatorValue,
}

class OverlayMacd extends OverlayChart {
  final List<MACD> data;
  final Color signalColor;
  final Color macdColor;
  final Color upColor;
  final Color downColor;
  final double lineWidth;
  final double barWidth;

  OverlayMacd({super.overlayType = OverlayType.macd,
    required this.data,
    this.signalColor = Colors.orangeAccent,
    this.macdColor = Colors.blueAccent,
    this.upColor = Colors.greenAccent,
    this.downColor = Colors.redAccent,
    this.lineWidth = 1.2,
    this.barWidth = 4.0});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0 || data.isEmpty) return;

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

    final visibleData = data.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    final minValue = switch(type) {
      _OverlayType.signal => visibleData.reduce((curr, next) => curr.signal <= next.signal ? curr : next).signal,
      _OverlayType.indicatorValue => visibleData.reduce((curr, next) => curr.macd <= next.macd ? curr : next).macd
    };
    final maxValue = switch(type) {
      _OverlayType.signal => visibleData.reduce((curr, next) => curr.signal > next.signal ? curr : next).signal,
      _OverlayType.indicatorValue => visibleData.reduce((curr, next) => curr.macd > next.macd ? curr : next).macd
    };

    if (minValue == maxValue) return;

    final path = Path();
    bool started = false;

    for (var elem in visibleData) {
      final val = type == _OverlayType.signal ? elem.signal : elem.macd;
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
      ..color = upColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final painHistDown = Paint()
      ..color = downColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final visibleData = data.where((e) => !e.dateTime.isBefore(ctx.startDate) && !e.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    double maxHistAbs = visibleData.map((e) => e.hist.abs()).reduce(max);
    if (maxHistAbs == 0) return;

    final halfHeight = size.height * 0.5;
    final zeroY = halfHeight;
    for (final macd in visibleData) {
      final x = ctx.dateToPos(macd.dateTime, size);
      final hist = (macd.hist / maxHistAbs) * halfHeight;
      canvas.drawLine(Offset(x, zeroY), Offset(x, zeroY - hist), macd.hist >= 0 ? painHistUp : painHistDown);
    }
  }
}
