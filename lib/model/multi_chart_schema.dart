import 'dart:convert';

import 'cache_schema.dart';
import 'drawing_schema.dart';
import 'indicator_schema.dart';

enum MainChartType {
  candlestickPrice("Candlestick",),
  linePrice("Line"),
  bars("Bars"),
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

enum ChartType {
  candlestickPrice("Candlestick",),
  linePrice("Line"),
  bars("Bars");

  const ChartType(this.name);
  final String name;
}

class ChartConfig extends Cache {
  final bool mainChart;
  final bool visible;
  final ChartType drawingType;
  final Indicator? indicator;
  final List<DrawingFeature> drawingData;

  ChartConfig({
    required this.mainChart,
    required this.drawingType,
    this.visible = true,
    this.indicator,
    this.drawingData = const[]
  }) : super.from([]);

  @override
  factory ChartConfig.from(Map<String, dynamic> item) {
    final indicatorData = item['indicator'];
    Indicator? indicator;
    if (indicatorData is Map<String, dynamic> && indicatorData.isNotEmpty) {
      indicator = Indicator.fromMap(indicatorData);
    }

    final drawingData = (item['drawing_data'] as List<Object?>).map((e) {
      final type = DrawingFeature.from(e as Map<String, dynamic>);
      if (type == null) return null;
      switch (type) {
        case DrawFeatureType.line:
          return LineFeature.from(e);
        case DrawFeatureType.rectangle:
          return RectangleFeature.from(e);
        case DrawFeatureType.label:
          return LabelFeature.from(e);
      }
    }).whereType<DrawingFeature>().toList();

    return ChartConfig(
      mainChart: item["main_chart"] as bool,
      drawingType: ChartType.values.firstWhere((e) => e.name == item["drawing_type"] as String),
      visible: item["visible"] as bool,
      indicator: (indicator?.isDefault() ?? true) ? null : indicator,
      drawingData: drawingData,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    "main_chart": mainChart,
    "drawing_type": drawingType.name,
    "visible": visible,
    "indicator": indicator?.toMap() ?? {},
    "drawing_data": drawingData.map((e) => e.toMap()).toList(),
  };

  @override
  String toString() => drawingType.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartConfig && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  ChartConfig copyWith(bool? mainChart, ChartType? drawingType, bool? visible, Indicator? indicator, List<DrawingFeature>? drawingData) {
    return ChartConfig(
      mainChart: mainChart ?? this.mainChart,
      drawingType: drawingType ?? this.drawingType,
      visible: visible ?? this.visible,
      indicator: indicator ?? this.indicator,
      drawingData: drawingData ?? this.drawingData,);
  }
}

class MultiChartConfigSchema extends CacheSchema {
  static const String cacheName = "multi_chart";
  static const String sequenceName = "multi_chart_id_sequence";

  @override
  String get create =>
   '''
    CREATE TABLE IF NOT EXISTS $cacheName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      title TEXT NOT NULL UNIQUE,
      charts TEXT, -- JSON string
    );
  ''';

  @override
  String get createKey => "CREATE SEQUENCE IF NOT EXISTS $sequenceName START 1;";

  @override
  String get deleteAll => "DELETE FROM $cacheName;";

  @override
  String deleteOne(Cache cache) => "DELETE FROM $cacheName WHERE id = ${(cache as MultiChartConfig).id};";

  @override
  String get readAll => "SELECT * FROM $cacheName ORDER BY title;";

  @override
  String readOne(Cache cache) => "SELECT * FROM $cacheName WHERE id = ${(cache as MultiChartConfig).id};";

  @override
  String saveOne(Cache cache) {
    final multiChart = cache as MultiChartConfig;
    return '''
      INSERT INTO $cacheName 
      VALUES (
      nextval('$sequenceName'),
      '${multiChart.title}',
      '${jsonEncode(multiChart.charts.map((e) => e.toMap()).toList())}',
      ) ON CONFLICT(title) DO UPDATE SET
          charts = excluded.charts;
    ''';
  }

  @override
  String updateOne(Cache cache) {
    final multiChart = cache as MultiChartConfig;
    return '''
      UPDATE $cacheName
      SET title = '${multiChart.title}',
          charts = '${jsonEncode(multiChart.charts.map((e) => e.toMap()).toList())}',
      WHERE id = ${multiChart.id};
    ''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiChartConfigSchema && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class MultiChartConfig extends Cache {
  final int id;
  final String title;
  final List<ChartConfig> charts;

  final MainChartType mainChart;
  final List<SupplementChart> overlayCharts;

  MultiChartConfig({
    required this.id,
    required this.title,
    this.mainChart = MainChartType.linePrice,
    this.overlayCharts = const[],
    this.charts = const[],
  }) : super.from([]);

  void removeOverlayChart(SupplementChart suppChart) {
    overlayCharts.remove(suppChart);
  }

  @override
  factory MultiChartConfig.from(List<Object?> item) {
    if (item.length < 4) {
      final List<dynamic> jsonCharts = jsonDecode(item[2] as String);
      return MultiChartConfig(
        id: item[0] as int,
        title: item[1] as String,
        charts: jsonCharts.map((e) {
          final map = e as Map<String, dynamic>;
          return ChartConfig.from(map);
        }).toList()
      );
    }
    return defaultMultiChart();
  }

  @override
  Map<String, dynamic> toMap() =>{
    'id': id,
    'title': title,
    'charts': charts.map((e) => e.toMap()).toList(),
  };

  @override
  String toString() => title;

  static MultiChartConfig defaultMultiChart() => MultiChartConfig(id: -1, title: '', charts: []);

  MultiChartConfig copyWith(int? id, String? title, List<ChartConfig>? charts) {
    return MultiChartConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      charts: charts ?? this.charts,
    );
  }
}