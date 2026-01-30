import 'package:flutter/material.dart';
import 'package:invest_agent/utils/chart_utils.dart';
import 'package:intl/intl.dart' as intl;
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';


class SideAxisPainter extends CustomPainter{
  final double Function(DateTime? startDate, DateTime? endDate) minValue;
  final double Function(DateTime? startDate, DateTime? endDate) maxValue;
  final TextStyle style;
  final bool showLevelLines;
  final TimeController controller;

  SideAxisPainter({super.repaint,
    required this.controller,
    required this.minValue,
    required this.maxValue,
    this.showLevelLines = true,
    this.style = const TextStyle(color: Colors.white70, fontSize: 12)});

  void _drawDashedLine(Canvas canvas, Offset start, double width, double dashWidth, double dashSpace, Paint paint) {
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

  void drawLevelLines(Canvas canvas, Size size, int countLevels) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.0;

    final min = minValue(controller.visibleStart, controller.visibleEnd);
    final max = maxValue(controller.visibleStart, controller.visibleEnd);
    final double step = (max - min) / (countLevels - 1);

    for (var i = 0; i < countLevels; i++) {
      final value = min + (step * i);
      final y = valueToPos(currValue: value, min: min, max: max, height: size.height);
      _drawDashedLine(canvas, Offset(0, y), size.width, 5, 3, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const countLevels = 5;
    if (showLevelLines) {
      drawLevelLines(canvas, size, countLevels);
    }

    final min = minValue(controller.visibleStart, controller.visibleEnd);
    final max = maxValue(controller.visibleStart, controller.visibleEnd);

    for (int i = 0; i <= countLevels; ++i) {
      final ratio = i / countLevels;
      final value = min + (max - min) * ratio;
      final y = valueToPos(currValue: value, min: min, max: max, height: size.height);

      final String compactNumber = intl.NumberFormat.compact().format(value);
      final textPainter = TextPainter(
        text: TextSpan(text: compactNumber, style: style),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: size.width);

      final textOffset = Offset(4, y - textPainter.height / 2); // Added 4px left padding
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant SideAxisPainter oldDelegate) {
    return oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.style != style ||
        oldDelegate.showLevelLines != showLevelLines ||
        oldDelegate.controller != controller;
  }
}
