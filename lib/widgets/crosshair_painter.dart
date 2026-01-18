import 'package:flutter/material.dart';

class CrosshairPainter extends CustomPainter {
  final double? x;

  CrosshairPainter(this.x);

  @override
  void paint(Canvas canvas, Size size) {
    if (x == null) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(x!, 0),
      Offset(x!, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CrosshairPainter old) => old.x != x;
}
