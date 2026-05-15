import 'multi_chart_schema.dart';

class ChartsConfiguration {
  final List<MultiChartConfig> multiCharts;

  // static const Map<MainChartType, List<SupplementChart>> _profileRules = {
  //   MainChartType.candlestickPrice: [
  //     SupplementChart.bb, SupplementChart.sma,
  //     SupplementChart.deathCross,
  //     SupplementChart.goldenCross,
  //     SupplementChart.ema,
  //     SupplementChart.emaSignal],
  //   MainChartType.linePrice: [
  //     SupplementChart.bb, SupplementChart.sma,
  //     SupplementChart.deathCross,
  //     SupplementChart.goldenCross,
  //     SupplementChart.ema,
  //     SupplementChart.emaSignal]
  // };

  ChartsConfiguration({this.multiCharts = const []});

  static bool validate(MultiChartConfig chart) {
    // final availableSuppCharts = _profileRules[chart.mainChart];
    // if (availableSuppCharts != null) {
    //   return chart.overlayCharts.every((suppChart) => availableSuppCharts.contains(suppChart));
    // }
    return true;
  }

  void addChart(MultiChartConfig newChart) {
    if (ChartsConfiguration.validate(newChart)) {
      multiCharts.add(newChart);
    }
  }

  void removeChart(MultiChartConfig chart) {
    multiCharts.remove(chart);
  }
}