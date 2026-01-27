import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';

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

    final int firstVisibleIndex = data.indexWhere(
            (elem) => elem.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw
    final minValue = switch(type) {
      _OverlayType.signal => data.skip(firstVisibleIndex).reduce((curr, next) => curr.signal <= next.signal ? curr : next).signal,
      _OverlayType.indicatorValue => data.skip(firstVisibleIndex).reduce((curr, next) => curr.macd <= next.macd ? curr : next).macd
    };
    final maxValue = switch(type) {
      _OverlayType.signal => data.skip(firstVisibleIndex).reduce((curr, next) => curr.signal > next.signal ? curr : next).signal,
      _OverlayType.indicatorValue => data.skip(firstVisibleIndex).reduce((curr, next) => curr.macd > next.macd ? curr : next).macd
    };
    final firstVal = switch(type) {
      _OverlayType.signal => data[firstVisibleIndex].signal,
      _OverlayType.indicatorValue => data[firstVisibleIndex].macd,
    };

    final path = Path();
    path.moveTo(
        ctx.dateToPos(data[firstVisibleIndex].dateTime, size),
        ctx.indicatorToPos(firstVal, minValue, maxValue, size.height));
    for (var elem in data.skip(firstVisibleIndex)) {
      if (elem.dateTime.isBefore(ctx.startDate) || elem.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final val = switch(type) {
        _OverlayType.signal => elem.signal,
        _OverlayType.indicatorValue => elem.macd,
      };
      final Offset offset = Offset(ctx.dateToPos(elem.dateTime, size),
          ctx.indicatorToPos(val, minValue, maxValue, size.height));
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
    for (final  macd in data) {
      if (macd.dateTime.isBefore(ctx.startDate) || macd.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      maxHistAbs = max(maxHistAbs, macd.hist.abs());
    }
    if (maxHistAbs == 0) return;

    // Zero Line
    final halfHeight = size.height * 0.5;
    final zeroY = halfHeight;
    for (final macd in data) {
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