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

class ChartConfig {
  final int id;
  final bool mainChart;
  final bool visible;
  final ChartType drawingType;
  final Indicator? indicator;
  final List<DrawingFeature> drawingData;

  ChartConfig({
    required this.id,
    required this.mainChart,
    required this.drawingType,
    this.visible = true,
    this.indicator,
    this.drawingData = const[]
  });

  factory ChartConfig.from(List<Object?> item) {
    final jsonIndicator  = Indicator.from(item[4] as List<Object?>);
    final drawingData = (item[5] as List<Object?>).map((e) => DrawingFeature.from(e as List<Object?>)).toList();
    return ChartConfig(
      id: item[0] as int,
      mainChart: item[1] as bool,
      drawingType: ChartType.values.firstWhere((e) => e.name == item[2] as String),
      visible: item[3] as bool,
      indicator: jsonIndicator.isDefault() ? null : jsonIndicator,
      drawingData: drawingData,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "main_chart": mainChart,
    "drawing_type": drawingType.name,
    "visible": visible,
    "indicator": indicator?.toMap() ?? {},
    "drawing_data": drawingData.map((e) => e.toMap()).toList(),
  };
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
      charts TEXT NOT NULL, -- JSON string
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
      '${multiChart.charts.map((e) => e.toMap()).toList()}',
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
          charts = '${multiChart.charts.map((e) => e.toMap()).toList()}',
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
    return MultiChartConfig(
      id: item[0] as int,
      title: item[1] as String,
      charts: (item[2] as List<Object?>).map((e) => ChartConfig.from(e as List<Object?>)).toList(),
    );
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
}