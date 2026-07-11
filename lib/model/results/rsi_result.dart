import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import '../indicator_result.dart';
import 'package:collection/collection.dart';

enum RsiParam {
  rsi("rsi"),
  window("window"),
  smoothLength("smooth length"),
  smoothType("smooth type"),
  upperLimit("upper limit"),
  lowerLimit("lower limit"),
  middleLimit("middle limit"),
  rsiChart("rsi chart"),
  smoothRsi("smooth rsi"),
  upperLevel("upper level"),
  middleLevel("middle level"),
  lowerLevel("lower level");

  final String name;
  const RsiParam(this.name);
}

class Rsi extends BaseIndicatorValue {
  final double? rsi;
  final int? window;

  Rsi({
    required super.dateTime,
    required this.rsi,
    required this.window,});

  factory Rsi.fromType(DateTime dateTime, {rsi = double, window = int}) {
    return Rsi(dateTime: dateTime, rsi: rsi, window: window);
  }

  static Rsi? fromJson(
      DateTime dateTime, Map<String, dynamic> jsonMap, String jsonMacdType) {
    final rsi = parseNum(jsonMap[RsiParam.rsi.name]);
    final window = jsonMap[RsiParam.window.name] as int?;
    if (rsi != null && window != null) {
      return Rsi(dateTime: dateTime, rsi: rsi,  window: window,);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    RsiParam.rsi.name: rsi,
    RsiParam.window.name: window,
  };
}

class RsiResult extends BaseIndicatorResult {
  final List<Rsi> points;

  RsiResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory RsiResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
    final style = ChartStyle.values.firstWhereOrNull(
          (e) => e.name == protoResult.chartStyle,
    ) ?? ChartStyle.line;

    final config = Indicator(
      id: protoResult.config.id,
      name: protoResult.config.name,
      type: type,
      parameters: protoResult.config.parameters.toProto3Json() as Map<String, dynamic>,
    );

    final data = protoResult.points.map((p) {
      return Rsi(
        dateTime: p.dateTime.toDateTime(),
        rsi: p.values[RsiParam.rsi.name] ?? 0.0,
        window: p.values[RsiParam.window.name]?.toInt(),
      );
    }).toList();

    return RsiResult(
      style: style,
      config: config,
      points: data,
    );
  }

  List<Rsi> getPoints({int rollingWindow = 20}) {
    // return points.where((p) => p.rollingWindow == rollingWindow).toList();
    return points;
  }

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points.map((p) => p.rsi ?? -double.infinity).reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.rsi ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.rsi ?? -double.infinity).reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.rsi ?? double.infinity).reduce(min);
  }

  Iterable<Rsi> _filterPoints(DateTime? start, DateTime? end) {
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
    if (other is! RsiResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;
}
