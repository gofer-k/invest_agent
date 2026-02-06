import 'package:invest_agent/model/analysis_period.dart';

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

class MultiChart {
  final String title;
  final MainChartType mainChart;
  final List<SupplementChart> overlayCharts;
  const MultiChart({required this.title, this.mainChart = MainChartType.linePrice, this.overlayCharts = const[]});
  void removeOverlayChart(SupplementChart suppChart) {
    overlayCharts.remove(suppChart);
  }
}

class ChartsConfiguration {
  final List<MultiChart> multiCharts;
  final PeriodType periodType;

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

  ChartsConfiguration({this.periodType = PeriodType.year,
    this.multiCharts = const [MultiChart(title: "Price")]});

  static bool validate(MultiChart chart) {
    final availableSuppCharts = _profileRules[chart.mainChart];
    if (availableSuppCharts != null) {
      return chart.overlayCharts.every((suppChart) => availableSuppCharts.contains(suppChart));
    }
    return true;
  }

  void addChart(MultiChart newChart) {
    if (ChartsConfiguration.validate(newChart)) {
      multiCharts.add(newChart);
    }
  }

  void removeChart(MultiChart chart) {
    multiCharts.remove(chart);
  }
}