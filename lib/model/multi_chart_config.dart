enum MainChartType {
  candlestickPrice("Candlestick",),
  linePrice("Line"),
  macd("MACD"),
  volume("Volume"),
  rsi("RSI");

  const MainChartType(this.name);
  final String name;
}

enum SupplementChart {
  bb("BB - Bollinger Bands"),
  deathCross("DC - Death cross"),
  goldenCross("GC - Golden cross"),
  ema("EMA - exp. moving average"),
  emaSignal("EMA signal"),
  obv("OBV - on balance volume"),
  sma("MA - moving average");
  const SupplementChart(this.name);
  final String name;
}

class MultiChartConfig {
  final String title;
  final MainChartType mainChart;
  final List<SupplementChart> overlayCharts;
  const MultiChartConfig({required this.title, this.mainChart = MainChartType.linePrice, this.overlayCharts = const[]});
  void removeOverlayChart(SupplementChart suppChart) {
    overlayCharts.remove(suppChart);
  }
}