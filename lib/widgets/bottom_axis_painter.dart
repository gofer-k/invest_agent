import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/chart_utils.dart';

class BottomAxisPainter extends CustomPainter{
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle style;

  String _label = "";
  late TextPainter _timePainter;

  static const int _yearDays = 365;
  static const int _monthDays = 30;
  static const int _weekDays = 7;
  static const int _twiceYearDays = 365 * 2;
  static const int _twiceMonthDays = 30 * 2;
  static const int _twiceWeekDays = 7 * 2;

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

    final span = endDate.difference(startDate);
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.0;

    Duration step;
    if(span.inDays > _twiceYearDays) {
      step = Duration(days: _yearDays);
    }
    else if (span.inDays > _twiceMonthDays) {
      step = Duration(days: _monthDays);
    }
    else if(span.inDays > _twiceWeekDays) {
      step = Duration(days: _weekDays);
    }
    else {
      step = Duration(days: 1);
    }

    const double topMargin = 10.0;
    DateTime currTime = DateTime(startDate.year, startDate.month, startDate.day);
    while (currTime.isBefore(endDate)) {
      final x = dateToPos(currTime, startDate, endDate, size.width);

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      _label = _format(currTime, span);
      // Layout the painter if it hasn't been laid out or if constraints change.
      if (_timePainter.text?.toPlainText() != _label || _timePainter.width != 0.0) {
        _timePainter.text = TextSpan(text: _label, style: style);
        _timePainter.layout(maxWidth: size.width);
      }

      canvas.save();
      // Translate to the point where the text should be painted
      canvas.translate(x, topMargin + _timePainter.height / 2);
      // Rotate the canvas
      canvas.rotate(-pi / 4); // Negative for counter-clockwise
      _timePainter.paint(canvas, Offset(-_timePainter.width / 2, -_timePainter.height / 2));
      canvas.restore();

      currTime = currTime.add(step);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BottomAxisPainter oldDelegate) {
    return oldDelegate._label != _label || oldDelegate.style != style
        || oldDelegate.startDate != startDate || oldDelegate.endDate != endDate;
  }

  String _format(DateTime currTime, Duration span) {
    if (span.inDays > _twiceYearDays) return "${currTime.year}";
    if (span.inDays > _twiceMonthDays) return _monthShort(currTime.month);
    if (span.inDays > _twiceWeekDays) return "${_monthShort(currTime.month)}/${currTime.day}";
    return "${_monthShort(currTime.month)}/${currTime.day}";
  }

  String _monthShort(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
