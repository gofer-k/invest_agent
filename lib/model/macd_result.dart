import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import 'indicator_result.dart';
import 'package:collection/collection.dart';

class MovingAverageConvergenceDivergence extends BaseIndicatorValue {
  final double? macd;
  final double? signal;
  final double? hist;
  final int? window;
  // {"fast": [9], "slow": [26]

  MovingAverageConvergenceDivergence({
    required super.dateTime,
    required this.macd,
    required this.signal,
    required this.hist,
    required this.window,});

  factory MovingAverageConvergenceDivergence.fromType(
      DateTime dateTime,
      {macd = double, signal = double, hist = double, window = int}) {
    return MovingAverageConvergenceDivergence(
        dateTime: dateTime, macd: macd, signal: signal, hist: hist, window: window);
  }

  static MovingAverageConvergenceDivergence? fromJson(
      DateTime dateTime, Map<String, dynamic> jsonMap, String jsonMacdType) {
    final macd = parseNum(jsonMap['value']);
    final signal = parseNum(jsonMap['signal']);
    final hist = parseNum(jsonMap['hist']);
    final window = jsonMap['window'] as int?;
    if (macd != null && signal != null && hist != null && window != null) {
      return MovingAverageConvergenceDivergence(
          dateTime: dateTime,
          macd: macd,
          signal: signal,
          hist: hist,
          window: window,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "value": macd,
    "signal": signal,
    "hist": hist,
    "window": window,
  };
}

class MacdResult extends BaseIndicatorResult {
  final List<MovingAverageConvergenceDivergence> data;

  MacdResult({
    required super.style,
    required super.config,
    required this.data,
  });

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
        macd: p.values['value'] ?? 0.0,
        signal: p.values['signal'] ?? 0.0,
        hist: p.values['hist'] ?? 0.0,
        window: (config.parameters['window'] as num?)?.toInt(),
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
}
