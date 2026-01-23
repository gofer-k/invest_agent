import 'dart:ui';

import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';

class OverlayBellingerBand extends OverlayChart {
  final BellingerBand band;
  final Color lineColor;
  final double strokeWidth;

  OverlayBellingerBand({required this.band, required this.lineColor, this.strokeWidth = 1.2});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = band.indexWhere(
            (ma) => ma.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw

    final path = Path();
    path.moveTo(
        ctx.dateToPos(band[firstVisibleIndex].dateTime, size),
        ctx.valueToPos(band[firstVisibleIndex].stdValue ?? 0.0, size));
    for (var value in band.skip(firstVisibleIndex)) {
      if (value.dateTime.isBefore(ctx.startDate) || value.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final Offset offset = Offset(ctx.dateToPos(value.dateTime, size),
          ctx.valueToPos(value.stdValue ?? 0.0, size));
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(path, paint);
  }
}