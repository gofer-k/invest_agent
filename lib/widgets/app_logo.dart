import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).splashColor;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: logoColor),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Background of the logo (optional, can be transparent or themed)
    // For now, let's just draw the icon marks with the primary color
    
    // Bar 1 (short)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.15, h * 0.25),
        Radius.circular(w * 0.05),
      ),
      paint,
    );

    // Bar 2 (medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.425, h * 0.4, w * 0.15, h * 0.4),
        Radius.circular(w * 0.05),
      ),
      paint,
    );

    // Bar 3 (tall + arrow head)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.25, w * 0.15, h * 0.55),
        Radius.circular(w * 0.05),
      ),
      paint,
    );

    // The "Assistant" spark (a small circle above the tall bar or a diagonal line)
    // Let's add an upward diagonal line crossing the bars
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.15, h * 0.75),
      Offset(w * 0.85, h * 0.15),
      linePaint,
    );
    
    // Arrow head
    final arrowPath = Path();
    arrowPath.moveTo(w * 0.85, h * 0.15);
    arrowPath.lineTo(w * 0.65, h * 0.18);
    arrowPath.moveTo(w * 0.85, h * 0.15);
    arrowPath.lineTo(w * 0.82, h * 0.35);
    
    canvas.drawPath(arrowPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
