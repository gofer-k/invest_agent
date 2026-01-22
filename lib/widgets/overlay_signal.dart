import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/chart_overlay.dart';

class OverlaySignal extends ChartOverlay {
  final DateTime date;
  final double value;
  Color signalColor;
  final String text;

  OverlaySignal({required this.date, required this.value,
    this.signalColor = Colors.green,
    this.text = ""});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (date.isBefore(ctx.startDate) || date.isAfter(ctx.endDate)) return;

    final x = ctx.dateToPos(date,size);
    final y = ctx.valueToPos(value, size);
    final paint = Paint()..color = signalColor;
    canvas.drawCircle(Offset(x, y), 4, paint);
  }

}