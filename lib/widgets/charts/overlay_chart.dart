import 'dart:ui';

enum OverlayType {
  bellingerBands,
  macd,
  movingAverage,
  obv,
  pattern,
  priceCandles,
  priceLine,
  rsi,
  signal,
  tooltip_marker,
  volume,
}

abstract class OverlayChart {
  final OverlayType overlayType;
  OverlayChart({required this.overlayType});
  void draw(Canvas canvas, Size size, OverlayContext ctx);
}

class OverlayContext {
  final DateTime startDate;
  final DateTime endDate;
  final double Function(DateTime date, Size size) dateToPos;
  final double Function(double value, double height) priceToPos;
  final double Function(double value, double min, double max, double height)
  indicatorToPos;

  OverlayContext({
    required this.startDate,
    required this.endDate,
    required this.dateToPos,
    required this.priceToPos,
    required this.indicatorToPos,
  });
}
