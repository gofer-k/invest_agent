
import 'package:flutter/material.dart';
import 'package:invest_agent/model/indicator_schema.dart';

import '../widgets/utils/math_icons.dart';

enum ChartStyle {
  candlestickPrice("Candlestick", CandlestickIcon(size: 20, color: Colors.white)),
  line("Line", Icon(Icons.trending_up, color: Colors.white, size: 20)),
  bars("Bars", Icon(Icons.bar_chart, color: Colors.white, size: 20));

  const ChartStyle(this.name, this.icon);
  final String name;
  final Widget icon;

  @override
  String toString() => name;
}

abstract class BaseIndicatorValue {
  final DateTime dateTime;
  const BaseIndicatorValue({required this.dateTime});
}

typedef IndicatorResult = BaseIndicatorResult;
typedef IndicatorResultMap = Map<IndicatorKey, IndicatorResult>;

// Base indicator result for held an indicator's data
abstract class BaseIndicatorResult {
  final ChartStyle style;
  final Indicator config;
  double get maxValue;
  double get minValue;
  const BaseIndicatorResult({required this.style, required this.config});

  double getMin(DateTime? startDate, DateTime? endDate);
  double getMax(DateTime? startDate, DateTime? endDate);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseIndicatorResult) return false;
    return style == other.style && config == other.config;
  }

  @override
  int get hashCode => style.hashCode ^ config.hashCode;
}
