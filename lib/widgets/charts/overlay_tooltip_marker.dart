import 'package:flutter/material.dart';

import 'controllers/crosshair_controller.dart';
import 'overlay_chart.dart';

class OverlayTooltipMarker extends OverlayChart {
  final CrosshairController controller;

  OverlayTooltipMarker({required super.overlayType, required this.controller});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    final data = controller.data;
    if (data == null) return;

    final pos = data.position;

    // Vertical line
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(125)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(pos.dx, 0),
      Offset(pos.dx, size.height),
      linePaint,
    );

    // Circle marker
    final circlePaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 4, circlePaint);
  }
}
