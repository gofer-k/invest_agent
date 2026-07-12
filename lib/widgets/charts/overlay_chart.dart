import 'dart:ui';

import '../../utils/chart_utils.dart';

enum OverlayType {
  bollingerBands,
  macd,
  movingAverage,
  obv,
  pattern,
  priceCandles,
  priceLine,
  roc,
  rsi,
  signal,
  tooltipMarker,
  volume,
  empty, kst
}

abstract class OverlayChart {
  final OverlayType overlayType;
  OverlayChart({required this.overlayType});
  void draw(Canvas canvas, Size size, OverlayContext ctx);

  static void drawDashedLine(
      Canvas canvas, Offset start, double width, double dashWidth,
      double dashSpace, Paint paint) {
    double startX = start.dx;
    final endX = start.dx + width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, start.dy),
        Offset(startX + dashWidth, start.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  static void drawLevelLine(Canvas canvas, Size size, OverlayContext ctx,
    { required Color lineColor, required lineWidth,
      required double minBound,
      required double maxBound, required double level}) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap;

    // Guard against equal min/max or no data
    if (minBound == maxBound) return;
    final value =  level;
    final y = valueToPos(currValue: value, min: minBound, max: maxBound, height: size.height);

    OverlayChart.drawDashedLine(canvas, Offset(0, y), size.width, 5, 3, paint);
  }
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
