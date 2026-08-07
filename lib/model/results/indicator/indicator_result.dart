
import 'package:invest_agent/model/indicator_schema.dart';
import '../../chart_style.dart';

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
