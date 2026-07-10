import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/results/price_result.dart';

class OverlayPriceChart extends OverlayChart {
  final IndexPrice data;
  final Color lineColor;
  final double strokeWidth;

  OverlayPriceChart({
    super.overlayType = OverlayType.priceLine,
    required this.data,
    this.lineColor = Colors.white54,
    this.strokeWidth = 1.2,
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    final int firstVisibleIndex = data.priceData.indexWhere(
      (price) => !price.dateTime.isBefore(ctx.startDate),
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw
    final int startIndex = (firstVisibleIndex > 0) ? firstVisibleIndex - 1 : 0;

    // Suggestion 1: Iterate over pairs for clarity
    for (int i = startIndex + 1; i < data.priceData.length; ++i) {
      final prevPrice = data.priceData[i - 1];
      final currentPrice = data.priceData[i];

      // Stop drawing once we move past the visible area
      if (prevPrice.dateTime.isAfter(ctx.endDate)) {
        break;
      }

      final Offset prevOffset = Offset(
        ctx.dateToPos(prevPrice.dateTime, size),
        ctx.indicatorToPos(prevPrice.closePrice, size.height,
            data.getMin(ctx.startDate, ctx.endDate),
            data.getMax(ctx.startDate, ctx.endDate)
        ),
      );
      final Offset currOffset = Offset(
        ctx.dateToPos(currentPrice.dateTime, size),
        ctx.indicatorToPos(
            currentPrice.closePrice, size.height,
            data.getMin(ctx.startDate, ctx.endDate),
            data.getMax(ctx.startDate, ctx.endDate)),
      );
      canvas.drawLine(prevOffset, currOffset, paint);
    }
  }
}
