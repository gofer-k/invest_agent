import 'dart:ui';

import 'package:invest_agent/widgets/overlay_chart.dart';

class OverlayPattern extends OverlayChart {
  final DateTime startDate;
  final DateTime endDate;
  final double topValue;
  final double bottomValue;
  final Color patternsColor;

  OverlayPattern({required this.startDate, required this.endDate,
    required this.topValue,
    required this.bottomValue,
    this.patternsColor = const Color(0x44FFFF00)});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (endDate.isBefore(ctx.startDate) || startDate.isAfter(ctx.endDate)) return;

    final x1 = ctx.dateToPos(startDate, size);
    final x2 = ctx.dateToPos(endDate, size);
    final y1 = ctx.priceToPos(topValue, size.height);
    final y2 = ctx.priceToPos(bottomValue,size.height);
    final rect = Rect.fromLTRB(x1, y1, x2, y2);
    final paint = Paint()
      ..color = patternsColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }

}