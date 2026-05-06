import 'package:flutter/material.dart';
import '../../model/analysis_respond.dart';
import '../../model/charts_configuration.dart';
import '../../model/multi_chart_config.dart';
import '../../utils/chart_point.dart';
import 'controllers/crosshair_controller.dart';
import 'controllers/time_controller.dart';

class ChartContext {
  final MainChartType chartTYpe;
  final List<ChartPoint> chartPoints;
  final double Function(DateTime?, DateTime?) minFunc;
  final double Function(DateTime?, DateTime?) maxFunc;

  ChartContext({required this.chartTYpe, required this.chartPoints, required this.minFunc, required this.maxFunc});
}

class MultiChartScope extends InheritedWidget {
  final TimeController timeController;
  final CrosshairController? crosshairController;
  final ChartsConfiguration chartConfig;
  final List<ChartContext> contexts;

  MultiChartScope(AnalysisRespond results, {
    super.key,
    required super.child,
    required this.timeController,
    required this.chartConfig,
    this.crosshairController}) : contexts = _initializeChartsContext(results, chartConfig);

  static List<ChartContext> _initializeChartsContext(
      AnalysisRespond results, ChartsConfiguration chartConfig) {
    final List<ChartContext> initializedContexts = [];
    for (var chart in chartConfig.multiCharts) {
      final chartPoints = switch (chart.mainChart) {
        MainChartType.candlestickPrice =>
            results.getPriceData(20, null, null).map((item) =>
                ChartPoint(value: item.closePrice, dateTime: item.dateTime))
                .toList(),
        MainChartType.linePrice =>
            results.getPriceData(20, null, null).map((item) =>
                ChartPoint(value: item.closePrice, dateTime: item.dateTime))
                .toList(),
        MainChartType.macd =>
            results.getMacd(MACDType.MACD_12_26).map((item) =>
                ChartPoint(value: item.macd, dateTime: item.dateTime)).toList(),
        MainChartType.volume =>
            results.getPriceData(20, null, null).map((item) =>
                ChartPoint(value: item.volume, dateTime: item.dateTime))
                .toList(),
        MainChartType.rsi =>
            results.getRsi().map((item) =>
                ChartPoint(value: item.rsi, dateTime: item.dateTime)).toList(),
      };
      initializedContexts.add(ChartContext(chartTYpe: chart.mainChart,
          chartPoints: chartPoints,
          minFunc: _getMinValueFunc(chart.mainChart, results),
          maxFunc: _getMaxValueFunc(chart.mainChart, results)));
    }
    return initializedContexts;
  }

  static double Function(DateTime?, DateTime?) _getMaxValueFunc(MainChartType chartType, AnalysisRespond results) {
    return switch (chartType) {
      MainChartType.candlestickPrice => (startDate, endDate) => results.getMaxPrice(startDate, endDate),
      MainChartType.linePrice => (startDate, endDate) => results.getMaxPrice(startDate, endDate),
      MainChartType.macd => (startDate, endDate) => results.getMaxMACD(MACDType.MACD_12_26, startDate, endDate),
      MainChartType.volume => (startDate, endDate) => results.getMaxVolume(startDate, endDate),
      MainChartType.rsi => (startDate, endDate) => results.getMaxRsi(startDate, endDate)
     };
  }

  static double Function(DateTime?, DateTime?) _getMinValueFunc(MainChartType chartType, AnalysisRespond results) {
    return switch (chartType) {
      MainChartType.candlestickPrice => (startDate, endDate) => results.getMinPrice(startDate, endDate),
      MainChartType.linePrice => (startDate, endDate) => results.getMinPrice(startDate, endDate),
      MainChartType.macd => (startDate, endDate) =>  results.getMinMACD(MACDType.MACD_12_26, startDate, endDate),
      MainChartType.volume => (startDate, endDate) => results.getMinVolume(startDate, endDate),
      MainChartType.rsi => (startDate, endDate) => results.getMinRsi(startDate, endDate)
    };
  }
  
  static MultiChartScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultiChartScope>();
  }

  static MultiChartScope of(BuildContext context) {
    final MultiChartScope? result = maybeOf(context);
    assert(result != null, 'No MultiChartScope found in context');
    return result!;
  }

  ChartContext? by(MainChartType chartTYpe) {
    return contexts.where((context) => context.chartTYpe == chartTYpe).firstOrNull;
  }

  @override
  bool updateShouldNotify(covariant MultiChartScope oldWidget) {
    return timeController != oldWidget.timeController ||
        crosshairController != oldWidget.crosshairController ||
        chartConfig != oldWidget.chartConfig ||
        contexts != oldWidget.contexts;
  }
}