import 'analysis_period.dart';

enum IntervalType {
  day('1d'),
  week('1w'),
  month('1m'),
  year('1y');
  const IntervalType(this.value);
  final String value;

  @override
  String toString() => value;
}

class StrategyParams {
  final String type;
  final int? fast;
  final int? slow;

  StrategyParams({
    required this.type,
    this.fast,
    this.slow,
  });

  Map<String, dynamic> toJson() => {
    "type": type,
    "fast": fast,
    "slow": slow,
  };
}

class AnalysisRequest {
  final String symbolTicker;
  final String datasetSource;
  final PeriodType period;
  final IntervalType interval;
  final List<int>? rollingWindows;
  final StrategyParams? strategy;
  final List<String>? techIndicators;

  AnalysisRequest({
    required this.symbolTicker,
    required this.datasetSource,
    required this.period,
    required this.interval,
    this.rollingWindows,
    this.strategy,
    this.techIndicators
  });

  Map<String, dynamic> toJson() => {
    "symbol_ticker": symbolTicker,
    "dataset_source": datasetSource,
    "period": period.toString(),
    "interval": interval.toString(),
    "rolling_windows": rollingWindows,
    "strategy": strategy?.toJson(),
    "tech_indicators": techIndicators,
  };
}
