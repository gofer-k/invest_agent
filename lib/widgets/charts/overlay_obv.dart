import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

class OverlayOBV extends OverlayChart {
  final List<PriceData> data;
  final Color lineColor;
  final double lineWidth;

  OverlayOBV({
    super.overlayType = OverlayType.obv,
    required this.data,
    this.lineColor = Colors.purple,
    this.lineWidth = 1.2,
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (data.isEmpty) return;
    final int firstVisibleIndex = data.indexWhere(
      (elem) => elem.dateTime.isAfter(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final minValue = data
        .skip(firstVisibleIndex)
        .reduce((curr, next) => curr.volume <= next.volume ? curr : next)
        .volume;
    final maxValue = data
        .skip(firstVisibleIndex)
        .reduce((curr, next) => curr.volume > next.volume ? curr : next)
        .volume;

    final path = Path();
    for (final price in data.skip(firstVisibleIndex)) {
      if (price.dateTime.isBefore(ctx.startDate) ||
          price.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final Offset offset = Offset(
        ctx.dateToPos(price.dateTime, size),
        ctx.indicatorToPos(price.volume, minValue, maxValue, size.height),
      );
      path.lineTo(offset.dx, offset.dy);
    }
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    //TODO: smooth curve
    canvas.drawPath(path, paint);
  }
}
