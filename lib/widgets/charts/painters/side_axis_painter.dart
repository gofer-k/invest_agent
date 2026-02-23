import 'package:flutter/material.dart';
import 'package:invest_agent/utils/chart_utils.dart';
import 'package:intl/intl.dart' as intl;
import 'package:invest_agent/widgets/charts/controllers/time_controller.dart';

import '../../../model/axis_label.dart';


class SideAxisPainter extends CustomPainter{
  final double Function(DateTime? startDate, DateTime? endDate) minValue;
  final double Function(DateTime? startDate, DateTime? endDate) maxValue;
  final TextStyle style;
  final TimeController controller;
  final List<ValueLabel> highLightLabels;
  late TextPainter _valuePainter;

  SideAxisPainter({super.repaint,
    required this.controller,
    required this.minValue,
    required this.maxValue,
    required this.highLightLabels,
    this.style = const TextStyle(color: Colors.white70, fontSize: 12)}) {
    _valuePainter = TextPainter(
        text: TextSpan(text: "", style: style),
        textDirection: TextDirection.ltr);
  }

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

  void _drawLabel(Canvas canvas, Size size, double minValue, double maxValue, ValueLabel label) {
    final String compactNumber = intl.NumberFormat.compact().format(label.value);
    _valuePainter.text = TextSpan(text: compactNumber,
        style: style.copyWith(color: label.textColor));
    _valuePainter.layout();

    final y = valueToPos(currValue: label.value, min: minValue, max: maxValue, height: size.height);

    final rectWidth = _valuePainter.width + 12;
    final rectHeight = _valuePainter.height + 8;
    final backgroundRect = Rect.fromCenter(
      center: Offset(_valuePainter.width, y),
      width: rectWidth,
      height: rectHeight,
    );

    final rrect = RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4.0));
    final backgroundPaint = Paint()..color = label.backgroundColor;
    canvas.drawRRect(rrect, backgroundPaint);

    final outlinePaint = Paint()..color = label.textColor..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, outlinePaint);

    _valuePainter.paint(canvas, Offset(_valuePainter.width / 2, y - _valuePainter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const countLevels = 5;
    if (highLightLabels.isNotEmpty) {
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
    for(final label in highLightLabels) {
      _drawLabel(canvas, size, min, max, label);
    }
  }

  @override
  bool shouldRepaint(covariant SideAxisPainter oldDelegate) {
    return oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.style != style ||
        oldDelegate.controller != controller ||
        oldDelegate.highLightLabels != highLightLabels;
  }
}
