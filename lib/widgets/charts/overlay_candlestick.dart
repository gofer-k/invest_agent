import 'dart:ui';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';
import '../../model/price_result.dart';

class OverlayCandlestick extends OverlayChart {
  final List<IndexPriceItem> data;
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

    // Filter data to only what's visible to calculate correct local min/max
    final visibleData = data.where((p) => !p.dateTime.isBefore(ctx.startDate) && !p.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    double minPrice = visibleData.reduce((current, next) => current.lowPrice < next.lowPrice ? current : next).lowPrice;
    double maxPrice = visibleData.reduce((current, next) => current.highPrice > next.highPrice ? current : next).highPrice;
    
    final wickPaint = Paint()..strokeWidth = lineWidth;
    final bodyPaint = Paint()..style = PaintingStyle.fill;

    for (final price in visibleData) {
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
      final rect = Rect.fromLTRB(x - bodyWidth / 2, top, x + bodyWidth / 2, bottom);
      canvas.drawRect(rect, bodyPaint);
    }
  }

  double _priceToY(double val, double max, double min, Size size) {
    final range = max - min;
    if (range <= 0.0) return size.height / 2;
    final ratio = (val - min) / range;
    return size.height * (1 - ratio);
  }
}
