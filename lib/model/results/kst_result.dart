import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import '../indicator_result.dart';
import 'package:collection/collection.dart';

enum KstParam {
  // -- input parameters
  roc("roc"),
  sma("sma"),
  signalPeriod("signal period"),
  upperLimit("upper limit"),
  lowerLimit("lower limit"),
  kstChart("kst chart"),
  signalChart("signal chart"),
  upperLevel("upper level"),
  zeroLevel("zero level"),
  lowerLevel("lower level"),
  // -- output parameters
  kst("kst"),
  signal("signal");

  final String name;
  const KstParam(this.name);
}

class Kst extends BaseIndicatorValue {
  final double? kst;
  final double? signal;

  Kst({
    required super.dateTime,
    required this.kst,
    required this.signal,});

  factory Kst.fromType(DateTime dateTime, {kst = double, signal = double}) {
    return Kst(dateTime: dateTime, kst: kst, signal: signal);
  }

  static Kst? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final kst = parseNum(jsonMap[KstParam.kst.name]);
    final signal = parseNum(jsonMap[KstParam.signal.name]);
    if (kst != null && signal != null) {
      return Kst(dateTime: dateTime, kst: kst,  signal: signal);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    KstParam.kst.name: kst,
    KstParam.signal.name: signal,
  };
}

class KstResult extends BaseIndicatorResult {
  final List<Kst> points;

  KstResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory KstResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
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
      return Kst(
        dateTime: p.dateTime.toDateTime(),
        kst: p.values[KstParam.kst.name] ?? 0.0,
        signal: p.values[KstParam.signal.name] ?? 0.0,
      );
    }).toList();

    return KstResult(
      style: style,
      config: config,
      points: data,
    );
  }

  List<Kst> getPoints() => points;

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points.map((p) => p.kst ?? -double.infinity).reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.kst ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.kst ?? -double.infinity).reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.kst ?? double.infinity).reduce(min);
  }

  Iterable<Kst> _filterPoints(DateTime? start, DateTime? end) {
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
    if (other is! KstResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;
}
