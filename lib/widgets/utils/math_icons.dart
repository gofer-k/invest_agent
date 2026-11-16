import 'package:flutter/material.dart';

class MathIntegralIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const MathIntegralIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IntegralPainter(color: iconColor),
      ),
    );
  }
}

class _IntegralPainter extends CustomPainter {
  final Color color;

  _IntegralPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // 1. Draw stylized "Area under the curve"
    final areaPaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;

    final areaPath = Path();
    areaPath.moveTo(w * 0.1, h * 0.8);
    areaPath.quadraticBezierTo(w * 0.4, h * 0.2, w * 0.7, h * 0.6);
    areaPath.lineTo(w * 0.7, h * 0.8);
    areaPath.close();
    canvas.drawPath(areaPath, areaPaint);

    // 2. Draw the Integral Symbol (∫)
    final path = Path();
    // Top hook
    path.moveTo(w * 0.6, h * 0.15);
    path.quadraticBezierTo(w * 0.3, h * 0.1, w * 0.4, h * 0.45);
    // Middle stem
    path.lineTo(w * 0.4, h * 0.55);
    // Bottom hook
    path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.2, h * 0.85);
    canvas.drawPath(path, paint);

    // 3. Draw the "x" parameter on the right
    const textSpan = TextSpan(
      text: 'x',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontFamily: 'serif', // Gives it a mathematical look
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    // Adjust text style color and size dynamically based on icon size
    textPainter.text = TextSpan(
      text: 'x',
      style: TextStyle(
        color: color,
        fontSize: size.width * 0.45, // Scale font size relative to icon
        fontStyle: FontStyle.italic,
        fontFamily: 'serif',
      ),
    );

    textPainter.layout();

    // Position the 'x' to the right of the integral stem
    textPainter.paint(canvas, Offset(w * 0.55, h * 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CandlestickIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CandlestickIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CandlestickPainter(color: iconColor),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final Color color;

  _CandlestickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    final w = size.width;
    final h = size.height;

    // Draw three stylized candlesticks
    
    // 1. Green-ish (left)
    _drawCandle(canvas, paint, strokePaint, 
      Offset(w * 0.2, h * 0.5), // Wick top
      Offset(w * 0.2, h * 0.9), // Wick bottom
      Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.2, h * 0.3) // Body
    );

    // 2. Red-ish (center)
    _drawCandle(canvas, paint, strokePaint,
      Offset(w * 0.5, h * 0.9),
      Offset(w * 0.5, h * 0.7),
      Rect.fromLTWH(w * 0.4, h * 0.2, w * 0.2, h * 0.3)
    );

    // 3. Green-ish (right)
    _drawCandle(canvas, paint, strokePaint,
      Offset(w * 0.8, h * 0.6),
      Offset(w * 0.8, h * 0.2),
      Rect.fromLTWH(w * 0.7, h * 0.5, w * 0.2, h * 0.3)
    );
  }

  void _drawCandle(Canvas canvas, Paint fillPaint,
      Paint strokePaint,
      Offset wickTop,
      Offset wickBottom,
      Rect body) {
    canvas.drawLine(wickTop, wickBottom, strokePaint);
    canvas.drawRect(body, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
