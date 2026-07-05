import 'dart:ui';

enum OverlayType {
  bollingerBands,
  macd,
  movingAverage,
  obv,
  pattern,
  priceCandles,
  priceLine,
  rsi,
  signal,
  tooltipMarker,
  volume,
  empty
}

abstract class OverlayChart {
  final OverlayType overlayType;
  OverlayChart({required this.overlayType});
  void draw(Canvas canvas, Size size, OverlayContext ctx);
}

class EmptyOverlayChart implements OverlayChart {
  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {}

  @override
  OverlayType get overlayType => OverlayType.empty;
}

class OverlayContext {
  final DateTime startDate;
  final DateTime endDate;
  final double Function(DateTime date, Size size) dateToPos;
  // final double Function(double value, double height) priceToPos;
  final double Function(double value, double height, double min, double max)
  indicatorToPos;

  OverlayContext({
    required this.startDate,
    required this.endDate,
    required this.dateToPos,
    // required this.priceToPos,
    required this.indicatorToPos,
  });
}
