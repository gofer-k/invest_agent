import 'package:flutter/material.dart';
import 'package:invest_agent/utils/custom_datetime_format.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../model/axis_label.dart';
import '../../../utils/chart_utils.dart';

class BottomAxisPainter extends CustomPainter{
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle style;
  final List<DateTimeLabel> highLightLabels;

  String _label = "";
  late TextPainter _timePainter;

  BottomAxisPainter({super.repaint, required this.startDate, required this.endDate,
    required this.highLightLabels,
    this.style = const TextStyle(color: Colors.white70, fontSize: 12)}) {
    _timePainter = TextPainter(
        text: TextSpan(text: _label, style: style),
        textDirection: TextDirection.ltr);
  }

  void _drawLabel(Canvas canvas, Size size, double topMargin, Duration timeSpan, DateTimeLabel label) {
    final dateText = DateFormat.yMMMd().format(label.time);
    _timePainter.text = TextSpan(text: dateText,
        style: style.copyWith(color: label.textColor));
    _timePainter.layout();

    final x = dateToPos(label.time, startDate, endDate, size.width);

    final rectWidth = _timePainter.width + 12;
    final rectHeight = _timePainter.height + 8;
    final backgroundRect = Rect.fromCenter(
      center: Offset(x - _timePainter.width / 2, topMargin),
      width: rectWidth,
      height: rectHeight,
    );

    final rrect = RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4.0));
    final backgroundPaint = Paint()..color = label.backgroundColor;
    canvas.drawRRect(rrect, backgroundPaint);

    final outlinePaint = Paint()..color = label.textColor..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, outlinePaint);

    _timePainter.paint(canvas, Offset(x - _timePainter.width, topMargin - _timePainter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    const double topMargin = 10.0;
    final span = endDate.difference(startDate);
    DateTime currTime = DateTime(startDate.year, startDate.month, startDate.day);

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
      _timePainter.paint(canvas, Offset(-_timePainter.width / 2, -_timePainter.height / 2));
      canvas.restore();
    });

    final highlightLabelMargin = topMargin * 2.0;
    for (final label in highLightLabels) {
     _drawLabel(canvas, size, highlightLabelMargin, span, label);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BottomAxisPainter oldDelegate) {
    return oldDelegate._label != _label || oldDelegate.style != style
        || oldDelegate.startDate != startDate || oldDelegate.endDate != endDate;
  }
}
