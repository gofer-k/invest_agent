import 'dart:math';

import 'package:invest_agent/model/proto/generated/invest_agent.pb.dart' hide IndicatorType, Indicator;
import 'package:invest_agent/model/indicator_schema.dart';
import 'analysis_respond.dart';
import 'indicator_result.dart';
import 'package:collection/collection.dart';

class ExponentialMovingAverage extends BaseIndicatorValue {
  final double? ema;
  final int? rollingWindow;

  ExponentialMovingAverage({required super.dateTime, this.ema, this.rollingWindow});
  static ExponentialMovingAverage? fromJson(DateTime dateTime, Map<String, dynamic> jsonMap) {
    final value = parseNum(jsonMap['value']);
    final rollingWindow = parseNum(jsonMap["window"]);
    if (value == null || rollingWindow == null) {
      return null;
    }
    return ExponentialMovingAverage(dateTime: dateTime, ema: value, rollingWindow: rollingWindow.toInt());
  }

  Map<String, dynamic> toJson() => {
    "value": ema,
    "window": rollingWindow,
  };
}

class EmaResult extends BaseIndicatorResult {
  final List<ExponentialMovingAverage> points;

  EmaResult({
    required super.style,
    required super.config,
    required this.points,
  });

  factory EmaResult.fromProto(IndicatorSeries protoResult, IndicatorType type) {
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
      return ExponentialMovingAverage(
        dateTime: p.dateTime.toDateTime(),
        ema: p.values['value'],        
        rollingWindow: (config.parameters['window'] as num?)?.toInt(),
      );
    }).toList();

    return EmaResult(
      style: style,
      config: config,
      points: points,
    );
  }

  List<ExponentialMovingAverage> getPoints({int rollingWindow = 20}) {
    return points.where((p) => p.rollingWindow == rollingWindow).toList();
  }

  @override
  double get maxValue => points.isEmpty
      ? 0
      : points.map((p) => p.ema ?? -double.infinity).reduce(max);

  @override
  double get minValue => points.isEmpty
      ? 0
      : points.map((p) => p.ema ?? double.infinity).reduce(min);

  @override
  double getMax(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.ema ?? -double.infinity).reduce(max);
  }

  @override
  double getMin(DateTime? startDate, DateTime? endDate) {
    final filtered = _filterPoints(startDate, endDate);
    return filtered.isEmpty
        ? 0
        : filtered.map((p) => p.ema ?? double.infinity).reduce(min);
  }

  Iterable<ExponentialMovingAverage> _filterPoints(DateTime? start, DateTime? end) {
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
    if (other is! EmaResult) return false;
    return super == other && points == other.points;
  }

  @override
  int get hashCode => super.hashCode ^ points.hashCode;
}
