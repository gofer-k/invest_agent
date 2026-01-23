import 'dart:ui';

abstract class OverlayChart {
  void draw(Canvas canvas, Size size,  OverlayContext ctx);
}

 class OverlayContext {
  final DateTime startDate;
  final DateTime endDate;
  final double Function(DateTime date, Size size) dateToPos;
  final double Function(double value, Size size) valueToPos;

  OverlayContext({required this.startDate, required this.endDate, required this.dateToPos, required this.valueToPos});
 }