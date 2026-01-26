import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/overlay_chart.dart';
import 'package:invest_agent/widgets/time_controller.dart';

import '../model/analysis_request.dart';
import '../model/analysis_respond.dart';
import '../utils/chart_utils.dart';
import 'crosshair_controller.dart';

class ChartPainter extends CustomPainter {
  final TimeController controller;
  final CrosshairController? crosshairController;
  final AnalysisRequest analysisRequest;
  final AnalysisRespond results;
  final List<OverlayChart> overlays;
  final double widthSideLabels;

  ChartPainter({required this.controller, this.crosshairController, required this.analysisRequest, required this.results, this.overlays = const[], this.widthSideLabels = 0.0});

  void _paintBackGround(Canvas canvas, Size size) {
    final paintBackGround = Paint()
      ..color = const Color(0xFF222222);
    canvas.drawRect(Offset.zero & size, paintBackGround);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1.0;

    DateTime currTime = DateTime(controller.visibleStart.year, controller.visibleStart.month, controller.visibleStart.day);
    final halfWidthSideLabels = widthSideLabels / 2.0;
    canvas.save();
    drawDatetimeIndicateLine(controller.visibleStart, controller.visibleEnd, currTime, (DateTime newTime) {
      final x = dateToPos(newTime, controller.visibleStart, controller.visibleEnd, size.width);
      canvas.drawLine(Offset(x + halfWidthSideLabels, 0), Offset(x + halfWidthSideLabels, size.height), paintGrid);
    });
    canvas.restore();
  }

  void _crosshairLine(Canvas canvas, Size size) {
    if (crosshairController?.time != null) {
      final currTime = crosshairController?.time;
      if (!currTime!.isBefore(controller.visibleStart) && !currTime.isAfter(controller.visibleEnd)) {
        final x = dateToPos(currTime, controller.visibleStart, controller.visibleEnd, size.width);
        final crossPaint = Paint()
          ..color = Colors.white.withAlpha(153)
          ..strokeWidth = 1.0;

        canvas.drawLine(Offset(x, 0), Offset(x, size.height), crossPaint);
      }
    }
  }

  void _drawOverlays(Canvas canvas, Size size) {
    final ctx = OverlayContext(startDate: controller.visibleStart, endDate: controller.visibleEnd,
        dateToPos: (date, size) => dateToPos(date, controller.visibleStart, controller.visibleEnd, size.width),
        priceToPos: (value, height) => valueToPos(currValue: value, min: results.minPrice, max: results.maxPrice, height: height),
        indicatorToPos: (value, min, max, height) => valueToPos(currValue: value, min: min, max: max, height: height)
    );
    for (var overlay in overlays) {
      overlay.draw(canvas, size, ctx);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Define a rectangle for the clipping area
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Save the canvas state and apply the clip
    canvas.save();
    canvas.clipRect(clipRect);

    final snapDays = controller.visibleEnd.difference(controller.visibleStart).inDays.toDouble();
    if (snapDays <= 0 || size.width <= 0) return;

    _paintBackGround(canvas, size);
    _paintGrid(canvas, size);
    _drawOverlays(canvas, size);
    _crosshairLine(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.crosshairController != crosshairController ||
        oldDelegate.results != results ||
        oldDelegate.analysisRequest != analysisRequest ||
        oldDelegate.overlays != overlays;
  }
}
