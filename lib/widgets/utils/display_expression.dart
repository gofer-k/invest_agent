import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DisplayExpression extends StatelessWidget {
  const DisplayExpression({
    super.key,
    required this.context,
    required this.expression,
    required this.scale,
    this.decoration,
    this.textStyle,
    this.outlineMargin = 2.0,
    this.alignment = Alignment.centerLeft,
  });

  final BuildContext context;
  final String expression;
  final double scale;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final double outlineMargin;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    final bool isTex = expression.contains(r'\') || expression.contains(r'$');

    Widget content;
    if (isTex) {
      // LaTeX formulas don't wrap automatically. 
      // We wrap it in a horizontal scroll view to prevent horizontal clipping.
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          expression,
          textStyle: style,
          mathStyle: MathStyle.display,
          textScaleFactor: scale,
          onErrorFallback: (e) => Text(
            'Math Error: ${e.message}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    } else {
      // Plain text: 'softWrap' and no 'maxLines' allows it to "extend" vertically.
      content = Text(
        expression,
        style: style?.copyWith(fontSize: (style.fontSize ?? 14) * scale),
        softWrap: true,
      );
    }

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: EdgeInsets.all(outlineMargin),
      decoration: decoration,
      child: content,
    );
  }
}
