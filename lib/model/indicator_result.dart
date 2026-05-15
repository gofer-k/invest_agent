
import 'package:invest_agent/model/indicator_schema.dart';

enum ChartStyle {
  candlestickPrice("Candlestick"),
  line("Line"),
  bars("Bars");

  const ChartStyle(this.name);
  final String name;
}

abstract class BaseIndicatorValue {
  final DateTime dateTime;
  const BaseIndicatorValue({required this.dateTime});
}

// Base indicator result for held an indicator's data
abstract class BaseIndicatorResult {
  final ChartStyle style;
  final Indicator config;
  double get maxValue;
  double get minValue;
  const BaseIndicatorResult({required this.style, required this.config});

  double getMin(DateTime? startDate, DateTime? endDate);
  double getMax(DateTime? startDate, DateTime? endDate);
}

