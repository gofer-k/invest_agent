import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:invest_agent/model/asset_config.dart';

import 'analysis_period.dart';
import 'cache_schema.dart';
import 'drawing_schema.dart';
import 'indicator_result.dart';
import 'indicator_schema.dart';

class ChartConfig extends Cache {
  final bool mainChart;
  final bool visible;
  final ChartStyle chartStyle;
  final Indicator indicatorConfig; // price or indicator
  final List<DrawingFeature> drawingData; // the parent chart's drawing features

  ChartConfig({
    required this.mainChart,
    required this.chartStyle,
    this.visible = true,
    required this.indicatorConfig,
    this.drawingData = const[]
  }) : super.from([]);

  ChartConfig copyWith({
    bool? mainChart,
    ChartStyle? drawingType,
    bool? visible,
    Indicator? newIndicatorConfig,
    List<DrawingFeature>? drawingData}) {
    return ChartConfig(
      mainChart: mainChart ?? this.mainChart,
      chartStyle: drawingType ?? chartStyle,
      visible: visible ?? this.visible,
      indicatorConfig: newIndicatorConfig ?? indicatorConfig,
      drawingData: drawingData ?? this.drawingData,);
  }

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
      chartStyle: ChartStyle.values.firstWhere((e) => e.name == item["drawing_type"] as String),
      visible: item["visible"] as bool,
      indicatorConfig: indicator ?? Indicator.defaultIndicator(),
      drawingData: drawingData,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    "main_chart": mainChart,
    "drawing_type": chartStyle.name,
    "visible": visible,
    "indicator": indicatorConfig.toMap(),
    "drawing_data": drawingData.map((e) => e.toMap()).toList(),
  };

  @override
  String toString() {
   return "${chartStyle.name}, [${indicatorConfig.toDetailedString()}]";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartConfig &&
          runtimeType == other.runtimeType &&
          mainChart == other.mainChart &&
          visible == other.visible &&
          chartStyle == other.chartStyle &&
          indicatorConfig == other.indicatorConfig;

  @override
  int get hashCode =>
      mainChart.hashCode ^
      visible.hashCode ^
      chartStyle.hashCode ^
      indicatorConfig.hashCode;

  @override
  List<Object?> get props => [mainChart, visible, chartStyle, indicatorConfig];

}

// -- Multi chart schema --
class MultiChartConfigSchema extends CacheSchema {
  static const String cacheName = "multi_chart";
  static const String sequenceName = "multi_chart_id_sequence";

  @override
  String get create =>
   '''
    CREATE TABLE IF NOT EXISTS $cacheName (
      id INTEGER PRIMARY KEY DEFAULT nextval('$sequenceName'),
      asset_id INTEGER,
      title TEXT NOT NULL UNIQUE,
      period_type TEXT,
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
      ${multiChart.asset.id},
      '${multiChart.title}',
      '${multiChart.periodType.name}',
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
          asset_id = ${multiChart.asset.id},
          period_type = '${multiChart.periodType.name}',
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
  final String title; // Asset's name
  final List<ChartConfig> charts;
  final PeriodType periodType;
  final AssetConfig asset;

  MultiChartConfig({
    required this.id,
    required this.title,
    required this.asset,
    this.charts = const[],
    this.periodType = PeriodType.year,
  }) : super.from([]);

  MultiChartConfig copyWith({
    int? newId, String? newTitle, AssetConfig? newAsset,
    PeriodType? newPeriodType,
    List<ChartConfig>? newCharts}) {
    return MultiChartConfig(
      id: newId ?? id,
      title: newTitle ?? title,
      asset: newAsset ?? asset,
      periodType: newPeriodType ?? periodType,
      charts: newCharts ?? charts,
    );
  }

  @override
  factory MultiChartConfig.from(List<Object?> item) {
    if (item.length >= 5) {
      final List<dynamic> jsonCharts = jsonDecode(item[4] as String);
      final jsonAssetId = item[1] as int;
      return MultiChartConfig(
        id: item[0] as int,
        asset: AssetConfig.of(id: jsonAssetId),
        title: item[2] as String,
        periodType: PeriodType.values.firstWhere((e) => e.name == item[3] as String),
        charts: jsonCharts.map((e) {
          final map = e as Map<String, dynamic>;
          return ChartConfig.from(map);
        }).toList(),
      );
    }
    return defaultMultiChart();
  }

  @override
  Map<String, dynamic> toMap() =>{
    'id': id,
    'asset_id': asset.id,
    'title': title,
    'period_type': periodType.name,
    'charts': charts.map((e) => e.toMap()).toList(),
  };

  @override
  String toString() => "$title, ${asset.toString()}, $periodType, [$charts]";

  static MultiChartConfig defaultMultiChart() =>
      MultiChartConfig(
        id: -1, title: '', periodType: PeriodType.year, charts: [],
        asset: AssetConfig.defaultAsset());

  static MultiChartConfig priceMultiChart(
    AssetConfig asset,
    PeriodType periodType,
    ChartStyle chartStyle) =>
    MultiChartConfig(
      id: -1, title: '',
      periodType: periodType,
      charts: [
        ChartConfig(mainChart: true, chartStyle: chartStyle,
          indicatorConfig: Indicator.priceIndicator())],
      asset: asset);

  ChartConfig get mainChart => charts.firstWhere((e) => e.mainChart);
  List<ChartConfig> get overlayCharts => charts.where((e) => !e.mainChart).toList();
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiChartConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          asset == other.asset &&
          title == other.title &&
          periodType == other.periodType &&
          const ListEquality().equals(charts, other.charts);

  @override
  int get hashCode =>
      id.hashCode ^
      asset.hashCode ^
      title.hashCode ^
      periodType.hashCode ^
      const ListEquality().hash(charts);

  @override
  List<Object?> get props => [id, asset, title, periodType, charts];
}
