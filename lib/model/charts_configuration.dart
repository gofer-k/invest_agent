import 'multi_chart_schema.dart';

class ChartsConfiguration {
  final List<MultiChartConfig> multiCharts;

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