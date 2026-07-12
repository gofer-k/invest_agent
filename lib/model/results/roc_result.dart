import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import '../indicator_result.dart';
import 'package:collection/collection.dart';

enum RocParam {
  // -- input parameters
  roc("roc"),
  window("window"),
  upperLimit("upper limit"),
  lowerLimit("lower limit"),
  rocChart("chart"),
  upperLevel("upper level"),
  zeroLevel("zero level"),
  lowerLevel("lower level");

  final String name;
  const RocParam(this.name);
}

class Roc extends BaseIndicatorValue {
  final double? roc;
  final int? window;

  Roc({
    required super.dateTime,
    required this.roc,
    required this.window,});

  factory Roc.fromType(DateTime dateTime, {roc = double, window = int}) {
    return Roc(dateTime: dateTime, roc: roc, window: window);
  }

  static Roc? fromJson(
      DateTime dateTime, Map<String, dynamic> jsonMap) {
    final roc = parseNum(jsonMap[RocParam.roc.name]);
    final window = jsonMap[RocParam.window.name] as int?;
    if (roc != null && window != null) {
      return Roc(dateTime: dateTime, roc: roc,  window: window,);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    RocParam.roc.name: roc,
    RocParam.window.name: window,
  };
}

class RocResult extends BaseIndicatorResult {
  final List<Roc> points;

  RocResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory RocResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
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
      return Roc(
        dateTime: p.dateTime.toDateTime(),
        roc: p.values[RocParam.roc.name] ?? 0.0,
        window: p.values[RocParam.window.name]?.toInt(),
      );
    }).toList();

    return RocResult(
      style: style,
      config: config,
      points: data,
    );
  }

  List<Roc> getPoints({int rollingWindow = 20}) {
    // return points.where((p) => p.rollingWindow == rollingWindow).toList();
    return points;
  }

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points.map((p) => p.roc ?? -double.infinity).reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.roc ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.roc ?? -double.infinity).reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.roc ?? double.infinity).reduce(min);
  }

  Iterable<Roc> _filterPoints(DateTime? start, DateTime? end) {
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
    if (other is! RocResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;
}
