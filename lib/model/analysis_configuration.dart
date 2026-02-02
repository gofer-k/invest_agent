enum MainChartType {
  candlestickPrice("Candlestick Price",),
  linePrice("Line Price"),
  macd("MACD"),
  volume("Volume"),
  rsi("RSI");

  const MainChartType(this.name);
  final String name;
}

enum SupplementChart {
  bb("BB - Bollinger Bands"),
  deathCross("Death cross"),
  goldenCross("Golden cross"),
  ema("EMA - exponential Moving Average"),
  emaSignal("EMA Signal"),
  obv("OBV - on balance volume"),
  sma("MA - moving average");
  const SupplementChart(this.name);
  final String name;
}

class MultiChart {
  String title;
  MainChartType mainChart;
  List<SupplementChart> overlayCharts;
  MultiChart({required this.title, required this.mainChart, required this.overlayCharts});
  void removeOverlayChart(SupplementChart suppChart) {
    overlayCharts.remove(suppChart);
  }
}

class AnalysisConfiguration {
  Map<MainChartType, List<SupplementChart>> profileChart;
  static const Map<MainChartType, List<SupplementChart>> _profileRules = {
    MainChartType.candlestickPrice: [
      SupplementChart.bb, SupplementChart.sma,
      SupplementChart.deathCross,
      SupplementChart.goldenCross,
      SupplementChart.ema,
      SupplementChart.emaSignal],
    MainChartType.linePrice: [
      SupplementChart.bb, SupplementChart.sma,
      SupplementChart.deathCross,
      SupplementChart.goldenCross,
      SupplementChart.ema,
      SupplementChart.emaSignal]
  };

  AnalysisConfiguration(): profileChart = {};

  bool _validate(MainChartType mainChartType, List<SupplementChart> suppCharts) {
    final availableSuppCharts = _profileRules[mainChartType];
    if (availableSuppCharts != null) {
      return suppCharts.every((suppChart) => availableSuppCharts.contains(suppChart));
    }
    return true;
  }

  bool addMainChart({required MainChartType chartType, List<SupplementChart> charts = const []}) {
    if (_validate(chartType, charts)) {
      profileChart[chartType] = charts;
      return true;
    }
    return false;
  }

  void removeMainChart(MainChartType chartType) {
    profileChart.remove(chartType);
  }

  void removeSupplementChart(MainChartType chartType, SupplementChart suppChart) {
    if (profileChart.containsKey(chartType)) {
      profileChart[chartType]!.remove(suppChart);
    }
  }
}