import 'package:flutter/material.dart';
import 'package:invest_agent/model/analysis_respond.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';

class OverlayPriceChart extends OverlayChart {
  final List<PriceData> data;
  final Color lineColor;
  final double strokeWidth;

  OverlayPriceChart({required this.data, this.lineColor = Colors.white54, this.strokeWidth = 1.2});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    final int firstVisibleIndex = data.indexWhere(
            (price) => !price.dateTime.isBefore(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw
    final int startIndex = (firstVisibleIndex > 0) ? firstVisibleIndex - 1 : 0;

    // Suggestion 1: Iterate over pairs for clarity
    for (int i = startIndex + 1; i < data.length; ++i) {
      final prevPrice = data[i - 1];
      final currentPrice = data[i];

      // Stop drawing once we move past the visible area
      if (prevPrice.dateTime.isAfter(ctx.endDate)) {
        break;
      }

      final Offset prevOffset = Offset(ctx.dateToPos(prevPrice.dateTime, size),
          ctx.valueToPos(prevPrice.closePrice, size));
      final Offset currOffset = Offset(ctx.dateToPos(currentPrice.dateTime, size),
          ctx.valueToPos(currentPrice.closePrice, size));
      canvas.drawLine(prevOffset, currOffset, paint);
    }
  }
}