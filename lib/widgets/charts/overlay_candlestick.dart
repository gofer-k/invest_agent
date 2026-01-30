import 'dart:ui';

import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/analysis_respond.dart';

class OverlayCandlestick extends OverlayChart {
  final List<PriceData> data;
  final Color upColor;
  final Color downColor;
  final double bodyWidth;
  final double lineWidth;

  OverlayCandlestick({super.overlayType = OverlayType.priceCandles,
    required this.data,
    this.upColor = const Color(0xFF4CAF50),
    this.downColor = const Color(0xFFF44336),
    this.bodyWidth = 5.0,
    this.lineWidth = 1.2});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (data.isEmpty) return;

    // TODO: check out the price in visible range
    double minPrice = data.reduce((current, next) => current.lowPrice < next.lowPrice ? current : next).lowPrice;
    double maxPrice = data.reduce((current, next) => current.highPrice > next.highPrice ? current : next).highPrice;
    final wickPaint = Paint()..strokeWidth = lineWidth;
    final bodyPaint = Paint()..style = PaintingStyle.fill;

    for (final price in data) {
      if (price.dateTime.isBefore(ctx.startDate) || price.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final x = ctx.dateToPos(price.dateTime, size);
      final highY = _priceToY(price.highPrice, maxPrice, minPrice, size);
      final lowY = _priceToY(price.lowPrice, maxPrice, minPrice, size);
      final openY = _priceToY(price.openPrice, maxPrice, minPrice, size);
      final closeY = _priceToY(price.closePrice, maxPrice, minPrice, size);

      final isUp = price.closePrice >= price.openPrice;
      final top = isUp ? openY : closeY;
      final bottom = isUp ? closeY : openY;
      final color = isUp ? upColor : downColor;
      wickPaint.color = color;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      bodyPaint.color = color;
      final rect = Rect.fromLTRB(x - bodyWidth / 2, top, x + bodyWidth, bottom);
      canvas.drawRect(rect, bodyPaint);

      // TODO: display candle signals
    }
  }

  double _priceToY(double val, double max, double min, Size size) {
    final range = max - min;
    if (range == 0.0)  return size.height / 2;
    final ratio = (val - min) / range;
    return size.height * (1 - ratio);
  }
}
