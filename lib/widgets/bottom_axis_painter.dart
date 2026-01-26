import 'package:flutter/material.dart';
import 'package:invest_agent/utils/custom_datetime_format.dart';

import '../utils/chart_utils.dart';

class BottomAxisPainter extends CustomPainter{
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle style;

  String _label = "";
  late TextPainter _timePainter;

  BottomAxisPainter({super.repaint, required this.startDate, required this.endDate,
    this.style = const TextStyle(color: Colors.white70, fontSize: 12)}) {
    _timePainter = TextPainter(
        text: TextSpan(text: _label, style: style),
        textDirection: TextDirection.ltr);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    const double topMargin = 10.0;
    final span = endDate.difference(startDate);
    DateTime currTime = DateTime(startDate.year, startDate.month, startDate.day);

    final paintGrid = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 1.0;

    drawDatetimeIndicateLine(startDate, endDate, currTime, (DateTime newTime) {
      _label = CustomDatetimeFormat.format(newTime, span);
      // Layout the painter if it hasn't been laid out or if constraints change.
      if (_timePainter.text?.toPlainText() != _label || _timePainter.width != 0.0) {
        _timePainter.text = TextSpan(text: _label, style: style);
        _timePainter.layout(maxWidth: size.width);
      }

      canvas.save();

      final x = dateToPos(newTime, startDate, endDate, size.width);

      // Translate to the point where the text should be painted
      canvas.translate(x, topMargin - _timePainter.height / 2);
      // Rotate the canvas
      // canvas.rotate(-pi / 4); // Negative for counter-clockwise
      _timePainter.paint(canvas, Offset(-_timePainter.width / 2, -_timePainter.height / 2));
      canvas.restore();
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BottomAxisPainter oldDelegate) {
    return oldDelegate._label != _label || oldDelegate.style != style
        || oldDelegate.startDate != startDate || oldDelegate.endDate != endDate;
  }
}
