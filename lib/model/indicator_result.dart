
import 'package:flutter/material.dart';
import 'package:invest_agent/model/indicator_schema.dart';
import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide Indicator, IndicatorType;
import 'dart:math';
import 'package:collection/collection.dart';

import '../widgets/utils/math_icons.dart';
import 'analysis_respond.dart';

enum ChartStyle {
  candlestickPrice("Candlestick", CandlestickIcon(size: 20, color: Colors.white)),
  line("Line", Icon(Icons.trending_up, color: Colors.white, size: 20)),
  bars("Bars", Icon(Icons.bar_chart, color: Colors.white, size: 20));

  const ChartStyle(this.name, this.icon);
  final String name;
  final Widget icon;

  @override
  String toString() => name;
}

abstract class BaseIndicatorValue {
  final DateTime dateTime;
  const BaseIndicatorValue({required this.dateTime});
}

typedef IndicatorResult = List<BaseIndicatorResult>;
typedef IndicatorResultMap = Map<IndicatorType, IndicatorResult>;

// Base indicator result for held an indicator's data
abstract class BaseIndicatorResult {
  final ChartStyle style;
  final Indicator config;
  double get maxValue;
  double get minValue;
  const BaseIndicatorResult({required this.style, required this.config});

  double getMin(DateTime? startDate, DateTime? endDate);
  double getMax(DateTime? startDate, DateTime? endDate);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseIndicatorResult) return false;
    return style == other.style && config == other.config;
  }

  @override
  int get hashCode => style.hashCode ^ config.hashCode;
}

class SimpleMovingAverage extends BaseIndicatorValue {
  final double? rollingStd;
  final double? rollingMean;
  final int? rollingWindow;

  SimpleMovingAverage({required super.dateTime, this.rollingWindow, this.rollingStd, this.rollingMean});

  static SimpleMovingAverage? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final rollingMean = parseNum(jsonMap['rolling_mean'] ?? jsonMap['mean']);
    final rollingStd = parseNum(jsonMap['rolling_std'] ?? jsonMap['std']);
    final rollingWindow = parseNum(jsonMap["window"]);
    if (rollingMean == null && rollingStd == null && rollingWindow == null) {
      return null;
    }

    return SimpleMovingAverage(
        dateTime: dateTime,
        rollingWindow: rollingWindow?.toInt(),
        rollingMean: rollingMean,
        rollingStd: rollingStd);
  }

  Map<String, dynamic> toJson() => {
    "rolling_mean": rollingMean,
    "rolling_std": rollingStd,
    "window": rollingWindow,
  };
}

class SmaResult extends BaseIndicatorResult {
  final List<SimpleMovingAverage> points;

  SmaResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory SmaResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
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
      final dynamic windowValue = p.values['window'] ?? config.parameters['window'];
      final int? window = (windowValue is num)
          ? windowValue.toInt()
          : (windowValue is List && windowValue.isNotEmpty)
              ? parseNum(windowValue.first)?.toInt()
              : parseNum(windowValue)?.toInt();

      return SimpleMovingAverage(
        dateTime: p.dateTime.toDateTime(),
        rollingMean: p.values['mean'] ?? p.values['rolling_mean'],
        rollingStd: p.values['std'] ?? p.values['rolling_std'],
        rollingWindow: window,
      );
    }).toList();

    return SmaResult(
      style: style,
      config: config,
      points: points,
    );
  }

  List<SimpleMovingAverage> getPoints({int rollingWindow = 20}) {
    return points.where((p) => p.rollingWindow == rollingWindow).toList();
  }

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points
          .map((p) => max(p.rollingMean ?? -double.infinity, p.rollingStd ?? -double.infinity))
          .reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points
          .map((p) => min(p.rollingMean ?? double.infinity, p.rollingStd ?? double.infinity))
          .reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered
            .map((p) => max(p.rollingMean ?? -double.infinity, p.rollingStd ?? -double.infinity))
            .reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered
            .map((p) => min(p.rollingMean ?? double.infinity, p.rollingStd ?? double.infinity))
            .reduce(min);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SmaResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;

  Iterable<SimpleMovingAverage> _filterPoints(DateTime? start, DateTime? end) {
    if (start == null && end == null) return points;
    return points.where((p) {
      if (start != null && p.dateTime.isBefore(start)) return false;
      if (end != null && p.dateTime.isAfter(end)) return false;
      return true;
    });
  }
}
