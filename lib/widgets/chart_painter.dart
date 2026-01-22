import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/chart_overlay.dart';
import 'package:invest_agent/widgets/time_controller.dart';

import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import 'crosshair_controller.dart';

class CHartPainter extends CustomPainter {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final AnalysisRequest analysisRequest;
  final AnalysisRespond results;
  final List<ChartOverlay> overlays;

  CHartPainter({required this.controller, this.crosshairController, required this.analysisRequest, required this.results, this.overlays = const[]});

  double _dateToPos(DateTime date, Size size) {
    final spanDays = controller.visibleEnd.difference(controller.visibleStart).inDays;
    final ratio = date.difference(controller.visibleStart).inDays / spanDays;
    return ratio * size.width;
  }

  double _valueToPos(double value, Size size) {
    final ratio = (value - results.getMinPrice()) / results.getPriceRange();
    return size.height * (1 - ratio);
  }

  void _paintBackGround(Canvas canvas, Size size) {
    final paintBackGround = Paint()
      ..color = const Color(0xFF222222);
    canvas.drawRect(Offset.zero & size, paintBackGround);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1.0;

    const gridLines = 5;
    for (var i = 0; i <= gridLines; ++i) {
      final x = size.width * i / gridLines;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
  }

  void _pricePriceLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.2;

    // TODO: pass prefixWindow from a user
    final priceData = results.getPriceData(20);
    final int firstVisibleIndex = priceData.indexWhere(
        (price) => !price.dateTime.isBefore(controller.visibleStart)
    );
    if (firstVisibleIndex == -1) return; // Nothing to draw
    final int startIndex = (firstVisibleIndex > 0) ? firstVisibleIndex - 1 : 0;

    // Suggestion 1: Iterate over pairs for clarity
    for (int i = startIndex + 1; i < priceData.length; ++i) {
      final prevPrice = priceData[i - 1];
      final currentPrice = priceData[i];

      // Stop drawing once we move past the visible area
      if (prevPrice.dateTime.isAfter(controller.visibleEnd)) {
        break;
      }

      final Offset prevOffset = Offset(_dateToPos(prevPrice.dateTime, size),
          _valueToPos(prevPrice.closePrice, size));
      final Offset currOffset = Offset(_dateToPos(currentPrice.dateTime, size),
          _valueToPos(currentPrice.closePrice, size));
      canvas.drawLine(prevOffset, currOffset, paint);
    }
   }


  void _crosshairLine(Canvas canvas, Size size) {
    if (crosshairController?.time != null) {
      final currTime = crosshairController?.time;
      if (!currTime!.isBefore(controller.visibleStart) && !currTime.isAfter(controller.visibleEnd)) {
        final x = _dateToPos(currTime, size);
        final crossPaint = Paint()
          ..color = Colors.white.withAlpha(153)
          ..strokeWidth = 1.0;

        canvas.drawLine(Offset(x, 0), Offset(x, size.height), crossPaint);
      }
    }
  }

  void _drawOverlays(Canvas canvas, Size size) {
    final ctx = OverlayContext(startDate: controller.visibleStart, endDate: controller.maxDomainEnd,
        dateToPos: (date, size) => _dateToPos(date, size),
        valueToPos: (value, size) => _valueToPos(value, size));
    for (var overlay in overlays) {
      overlay.draw(canvas, size, ctx);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final snapDays = controller.visibleEnd.difference(controller.visibleStart).inDays.toDouble();
    if (snapDays <= 0 || size.width <= 0) return;

    _paintBackGround(canvas, size);
    _paintGrid(canvas, size);
    _pricePriceLine(canvas, size);
    _crosshairLine(canvas, size);
    _drawOverlays(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CHartPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.crosshairController != crosshairController ||
        oldDelegate.results != results ||
        oldDelegate.analysisRequest != analysisRequest;
  }

  double priceToY(double price, double mimPrice, double maxPrice, double height) {
    final range = maxPrice - mimPrice;
    if (range == 0) return height /2;

    final ratio = (price - mimPrice) / range;
    return height * (1 - ratio);
  }
}
