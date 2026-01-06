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
  final String? interval;
  final List<int>? rollingWindows;
  final StrategyParams? strategy;
  final List<String>? factors;
  final List<String>? features;

  AnalysisRequest({
    required this.symbolTicker,
    required this.datasetSource,
    this.interval,
    this.rollingWindows,
    this.strategy,
    this.factors,
    this.features
  });

  Map<String, dynamic> toJson() => {
    "symbol_ticker": symbolTicker,
    "dataset_source": datasetSource,
    "interval": interval,
    "rolling_windows": rollingWindows,
    "strategy": strategy?.toJson(),
    "factors": factors,
    "features": features,
  };
}
