import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import '../indicator_result.dart';
import 'package:collection/collection.dart';

enum MacdParam {
  // -- Input parameters
  fast("fast"),
  slow("slow"),
  sigWindow("sig_window"),
  histUp("hist up"),
  histDown("hist down"),
  //  -- Output parameters
  macd("macd"),
  signal("signal"),
  hist("hist");
  final String name;
  const MacdParam(this.name);
}

class MovingAverageConvergenceDivergence extends BaseIndicatorValue {
  final double? macd;
  final double? signal;
  final double? hist;

  MovingAverageConvergenceDivergence({
    required super.dateTime,
    required this.macd,
    required this.signal,
    required this.hist});

  factory MovingAverageConvergenceDivergence.fromType(
      DateTime dateTime,
      {macd = double, signal = double, hist = double, window = int}) {
    return MovingAverageConvergenceDivergence(
        dateTime: dateTime, macd: macd, signal: signal, hist: hist);
  }

  static MovingAverageConvergenceDivergence? fromJson(
      DateTime dateTime, Map<String, dynamic> jsonMap) {
    final macd = parseNum(jsonMap[MacdParam.macd.name]);
    final signal = parseNum(jsonMap[MacdParam.signal.name]);
    final hist = parseNum(jsonMap[MacdParam.hist.name]);
    if (macd != null && signal != null && hist != null) {
      return MovingAverageConvergenceDivergence(
          dateTime: dateTime,
          macd: macd,
          signal: signal,
          hist: hist,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    MacdParam.macd.name: macd,
    MacdParam.signal.name: signal,
    MacdParam.hist.name: hist,
  };
}

class MacdResult extends BaseIndicatorResult {
  final List<MovingAverageConvergenceDivergence> data;

  MacdResult({
    required super.style,
    required super.config,
    required this.data,
  });

  List<MovingAverageConvergenceDivergence> getPoints() => data;

  factory MacdResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
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
      return MovingAverageConvergenceDivergence(
        dateTime: p.dateTime.toDateTime(),
        macd: p.values[MacdParam.macd.name] ?? 0.0,
        signal: p.values[MacdParam.signal.name] ?? 0.0,
        hist: p.values[MacdParam.hist.name] ?? 0.0,
      );
    }).toList();

    return MacdResult(
      style: style,
      config: config,
      data: data,
    );
  }

  @override
  double get maxValue => data.isEmpty
      ? 0
      : data.map((p) => p.macd ?? -double.infinity).reduce(max);

  @override
  double get minValue => data.isEmpty
      ? 0
      : data.map((p) => p.macd ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    double minMacd = filtered.isEmpty
        ? 0
        : filtered.map((p) => p.macd ?? -double.infinity).reduce(max);
    double minSignal = filtered.isEmpty
        ? 0
        : filtered.map((p) => p.signal ?? -double.infinity).reduce(max);
    return min(minMacd, minSignal);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    double minMacd = filtered.isEmpty
        ? 0
        : filtered.map((p) => p.macd ?? double.infinity).reduce(min);
    double minSignal = filtered.isEmpty
        ? 0
        : filtered.map((p) => p.signal ?? double.infinity).reduce(min);
    return min(minMacd, minSignal);
  }

  Iterable<MovingAverageConvergenceDivergence> _filterPoints(DateTime? start, DateTime? end) {
    if (start == null && end == null) return data;
    return data.where((p) {
      if (start != null && p.dateTime.isBefore(start)) return false;
      if (end != null && p.dateTime.isAfter(end)) return false;
      return true;
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MacdResult) return false;
    return super == other && data == other.data;
  }

  @override
  int get hashCode => super.hashCode ^ data.hashCode;
}
