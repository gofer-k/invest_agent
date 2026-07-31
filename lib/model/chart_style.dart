import 'package:flutter/material.dart';

import '../widgets/utils/math_icons.dart';

enum ChartStyle {
  candlestickPrice("Candlestick", CandlestickIcon(size: 20, color: Colors.white)),
  line("Line", Icon(Icons.trending_up, color: Colors.white, size: 20)),
  bars("Bars", Icon(Icons.bar_chart, color: Colors.white, size: 20)),
  undefined("Undefined", Icon(Icons.question_mark, color: Colors.white, size: 20));

  const ChartStyle(this.name, this.icon);
  final String name;
  final Widget icon;

  @override
  String toString() => name;
}