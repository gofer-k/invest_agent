import 'package:flutter/material.dart';
import 'package:invest_agent/model/chart_style.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/results/price_result.dart';

class OverlayPriceChart extends OverlayChart {
  final IndexPrice data;
  final Color lineColor;
  final double strokeWidth;

  OverlayPriceChart({
    super.overlayType = OverlayType.price,
    required super.chartStyle,
    required this.data,
    this.lineColor = Colors.white54,
    this.strokeWidth = 1.2,
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    switch (chartStyle) {
      case ChartStyle.candlestickPrice:
        _drawCandleSticks(canvas, size, ctx);
      case ChartStyle.line:
        _drawPriceLine(canvas, size, ctx);
      case _:
        break;
    }
  }

void _drawPriceLine(Canvas canvas, Size size, OverlayContext ctx) {
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

  // TODO: support customizable intervals and test this method
  void _drawCandleSticks(Canvas canvas, Size size, OverlayContext ctx) {
    if (data.priceData.isEmpty) return;

    final visibleData = data.priceData.where((p) => !p.dateTime.isBefore(ctx.startDate) && !p.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    // final double minPrice = data.getMin(ctx.startDate, ctx.endDate);
    // final double maxPrice = data.getMax(ctx.startDate, ctx.endDate);

    double minPrice = visibleData.reduce((current, next) => current.lowPrice < next.lowPrice ? current : next).lowPrice;
    double maxPrice = visibleData.reduce((current, next) => current.highPrice > next.highPrice ? current : next).highPrice;

    // Calculate width of one candle based on total visible space and data points
    final double candleWidth = (size.width / (data.priceData.length)) * 0.8;

    for (final price in visibleData) {
      // Skip if out of bounds
      // if (price.dateTime.isBefore(ctx.startDate)) continue;
      // if (price.dateTime.isAfter(ctx.endDate)) break;

      final double x = ctx.dateToPos(price.dateTime, size);

      // Map prices to Y coordinates
      final double openY = ctx.indicatorToPos(price.openPrice, size.height, minPrice, maxPrice);
      final double closeY = ctx.indicatorToPos(price.closePrice, size.height, minPrice, maxPrice);
      final double highY = ctx.indicatorToPos(price.highPrice, size.height, minPrice, maxPrice);
      final double lowY = ctx.indicatorToPos(price.lowPrice, size.height, minPrice, maxPrice);

      final isBullish = price.closePrice >= price.openPrice;
      final color = isBullish ? Colors.green : Colors.red;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = strokeWidth;

      // Draw the Wick (High to Low)
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), paint);

      // Draw the Body (Open to Close)
      final double top = isBullish ? closeY : openY;
      final double bottom = isBullish ? openY : closeY;

      // Ensure body has at least a tiny height if open == close
      final rectHeight = (bottom - top).abs().clamp(1.0, double.infinity);

      canvas.drawRect(
        Rect.fromLTWH(x - candleWidth / 2, top, x + candleWidth / 2, rectHeight),
        paint,
      );
    }
  }
}
