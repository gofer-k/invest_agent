import 'dart:ui';

import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/bollinger_bands_result.dart';

class OverlayBollingerBand extends OverlayChart {
  final List<BollingerBands> data;
  final Color lowerBandColor;
  final Color upperBandColor;
  final Color middleBandColor;
  final double strokeWidth;

  OverlayBollingerBand({super.overlayType = OverlayType.bollingerBands,
    required this.data,
    required this.lowerBandColor,
    required this.upperBandColor,
    required this.middleBandColor,
    this.strokeWidth = 1.2});

  void _drawBand(Canvas canvas, Size size, List<BollingerBands> data, BollingerBandParam typeBand,  OverlayContext ctx) {
    Color lineSelectedColor;
    double? Function(BollingerBands) valueSelector;

    switch (typeBand) {
      case BollingerBandParam.upperBB:
        lineSelectedColor = upperBandColor;
        valueSelector = (b) => b.upperBB;
        break;
      case BollingerBandParam.middleBB:
        lineSelectedColor = middleBandColor;
        valueSelector = (b) => b.middleBB;
        break;
      case BollingerBandParam.lowerBB:
      default:
        lineSelectedColor = lowerBandColor;
        valueSelector = (b) => b.lowerBB;
        break;
    }
    
    final paint = Paint()
      ..color = lineSelectedColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final int firstVisibleIndex = data.indexWhere(
            (ma) => ma.dateTime.isAfter(ctx.startDate)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw
    final visibleData = data.skip(firstVisibleIndex).toList();
    if (visibleData.isEmpty) return;

    final List<double> values = visibleData
        .map(valueSelector)
        .whereType<double>()
        .toList();

    if (values.isEmpty) return;

    final minBandValue = values.reduce((a, b) => a < b ? a : b);
    final maxBandValue = values.reduce((a, b) => a > b ? a : b);
    final path = Path();

    bool isFirstPoint = true;

    for (var item in visibleData) {
      if (item.dateTime.isAfter(ctx.endDate)) break;

      final val = valueSelector(item);
      if (val == null) continue;

      final double x = ctx.dateToPos(item.dateTime, size);
      final double y = ctx.indicatorToPos(val, size.height, minBandValue, maxBandValue);

      if (isFirstPoint) {
        path.moveTo(x, y);
        isFirstPoint = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (size.width <= 0) return;

    _drawBand(canvas, size, data, BollingerBandParam.lowerBB, ctx);
    _drawBand(canvas, size, data, BollingerBandParam.upperBB, ctx);
    _drawBand(canvas, size, data, BollingerBandParam.middleBB, ctx);
  }
}