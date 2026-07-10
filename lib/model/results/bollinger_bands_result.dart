import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import '../indicator_result.dart';
import 'package:collection/collection.dart';

enum BollingerBandParam {
  upperBB("BB_upper"),
  lowerBB("BB_lower"),
  medianBB("BB_median"),
  precentBB("BB_percent"),
  widthBB("BB_width"),
  window("window");

  final String name;
  const BollingerBandParam(this.name);

  @override
  String toString() => name;
}

class BollingerBands extends BaseIndicatorValue{
  final double? upperBB;
  final double? lowerBB;
  final double? medianBB;
  final double? widthBB;
  final double? percentBB;
  final int? rollingWindow;

  BollingerBands({
    required super.dateTime, this.upperBB, this.lowerBB, this.medianBB,
    this.widthBB, this.percentBB, this.rollingWindow});

  static BollingerBands? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    return BollingerBands(
        dateTime: dateTime,
        lowerBB: parseNum(jsonMap[BollingerBandParam.lowerBB.name]),
        upperBB: parseNum(jsonMap[BollingerBandParam.upperBB.name]),
        medianBB: parseNum(jsonMap[BollingerBandParam.medianBB.name]),
        percentBB: parseNum(jsonMap[BollingerBandParam.precentBB.name]),
        widthBB: parseNum(jsonMap[BollingerBandParam.widthBB.name]),
        rollingWindow: parseNum(jsonMap[BollingerBandParam.window.name])?.toInt()
    );
  }

  Map<String, dynamic> toJson() => {
    BollingerBandParam.window.name: rollingWindow,
    BollingerBandParam.lowerBB.name: lowerBB,
    BollingerBandParam.upperBB.name: upperBB,
    BollingerBandParam.medianBB.name: medianBB,
    BollingerBandParam.precentBB.name: percentBB,
    BollingerBandParam.widthBB.name: widthBB,
  };
}

class BollingerBandsResult extends BaseIndicatorResult {
  final List<BollingerBands> points;

  BollingerBandsResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory BollingerBandsResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
    final style = ChartStyle.values.firstWhereOrNull(
          (e) => e.name == protoResult.chartStyle,
    ) ?? ChartStyle.line;

    final config = Indicator(
      id: protoResult.config.id,
      name: protoResult.config.name,
      type: type,
      parameters: protoResult.config.parameters.toProto3Json() as Map<String, dynamic>,
    );

    final points = protoResult.points.map((p) {
      // Safe extraction of the rolling window, handling both scalar and list types
      final dynamic windowValue = p.values[BollingerBandParam.window.name] ?? config.parameters[BollingerBandParam.window.name];
      final int? window = (windowValue is num)
          ? windowValue.toInt()
          : (windowValue is List && windowValue.isNotEmpty)
          ? parseNum(windowValue.first)?.toInt()
          : parseNum(windowValue)?.toInt();

      return BollingerBands(
        dateTime: p.dateTime.toDateTime(),
        lowerBB: p.values[BollingerBandParam.lowerBB.name],
        upperBB: p.values[BollingerBandParam.upperBB.name],
        medianBB: p.values[BollingerBandParam.medianBB.name],
        percentBB: p.values[BollingerBandParam.precentBB.name],
        widthBB: p.values[BollingerBandParam.widthBB.name],
        rollingWindow: window,
      );
    }).toList();

    return BollingerBandsResult(
      style: style,
      config: config,
      points: points,
    );
  }

  List<BollingerBands> getPoints({int rollingWindow = 20}) {
    // return points.where((p) => p.rollingWindow == rollingWindow).toList();
    return points;
  }

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points.map((p) => p.medianBB ?? -double.infinity).reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.medianBB ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.medianBB ?? -double.infinity).reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.medianBB ?? double.infinity).reduce(min);
  }

  Iterable<BollingerBands> _filterPoints(DateTime? start, DateTime? end) {
    if (start == null && end == null) return points;
    return points.where((p) {
      if (start != null && p.dateTime.isBefore(start)) return false;
      if (end != null && p.dateTime.isAfter(end)) return false;
      return true;
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BollingerBandsResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;
}
