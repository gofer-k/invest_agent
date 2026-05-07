import 'dart:math';

import 'package:flutter/material.dart';
import 'package:invest_agent/model/cache_schema.dart';

enum DrawFeatureType {
  line,
  rectangle,
  label;
}

enum LineStyle {
  solid,
  dashed,
  dotted;
}

abstract class DrawingFeature extends Cache {
  final DrawFeatureType type;

  DrawingFeature({required this.type}) : super.from([]);

  static DrawFeatureType? from(Map<String, dynamic> item) {
    if (item['type'] == null) return null;
    if (item['type'] is! String) return null;
    if (item['type'] == '') return null;
    if (item['type'] == 'null') return null;
    if (item['type'] == 'undefined') return null;
    if (item['type'] == 'NaN') return null;
    final type = item['type'] as String;
    return DrawFeatureType.values.firstWhere((e) => e.name == type);
  }

  @override
  String toString() => type.name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingFeature && runtimeType == other.runtimeType &&
      type == other.type;

  @override
  int get hashCode => runtimeType.hashCode ^ type.hashCode;
}

class LineFeature extends DrawingFeature {
  final Color color;
  final double width;
  final LineStyle style;
  final Point begin;
  final Point end;

  LineFeature({
    super.type = DrawFeatureType.line,
    this.color = Colors.black,
    this.width = 1.0,
    this.style = LineStyle.solid,
    required this.begin,
    required this.end});

  LineFeature copyWith(Color? color, double? width, LineStyle? style, Point? begin, Point? end) {
    return LineFeature(
      type: type,
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
      begin: begin ?? this.begin,
      end: end ?? this.end,
  }

  @override
  Map<String, dynamic> toMap() => {
    "type": type.name,
    "color": color.toARGB32(),
    "width": width,
    "style": style.name,
    "begin": begin.toMap(),
    "end": end.toMap(),
  };

  @override
  factory LineFeature.from(Map<String, dynamic> item) {
    return LineFeature(
      type: item['type'] as DrawFeatureType,
      color: Color(item['color'] as int),
      width: item['width'] as double,
      begin: item['begin'] as Point,
      end: item['end'] as Point,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineFeature && runtimeType == other.runtimeType &&
      super.type == other.type &&
      color == other.color &&
      width == other.width &&
      style == other.style &&
      begin == other.begin &&
      end == other.end;

  @override
  int get hashCode => runtimeType.hashCode ^ super.hashCode ^ color.hashCode ^ width.hashCode ^ style.hashCode ^ begin.hashCode ^ end.hashCode;

  // TODO: builder api for LineFeature

  bool isHorizontal() => begin.y == end.y;
  bool isVertical() => begin.x == end.x;
}

class RectangleFeature extends DrawingFeature {
  final Color strokeColor;
  final Color fillColor;
  final double width;
  final LineStyle style;
  final Point leftTop;
  final Point rightBottom;

  RectangleFeature({
    super.type = DrawFeatureType.rectangle,
    this.strokeColor = Colors.black,
    this.fillColor = Colors.transparent,
    this.width = 1.0,
    this.style = LineStyle.solid,
    required this.leftTop,
    required this.rightBottom});

  RectangleFeature copyWith(Color? strokeColor, Color? fillColor, double? width, LineStyle? style, Point? leftTop, Point? rightBottom) {
    return RectangleFeature(
      type: type,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor ?? this.fillColor,
      width: width ?? this.width,
      style: style ?? this.style,
      leftTop: leftTop ?? this.leftTop,
      rightBottom: rightBottom ?? this.rightBottom,
    );
  }

  @override
  Map<String, dynamic> toMap() =>
    {
      "type": type.name,
      "strokeColor": strokeColor.toARGB32(),
      "fillColor": fillColor.toARGB32(),
      "width": width,
      "style": style.name,
      "leftTop": leftTop.toMap(),
      "rightBottom": rightBottom.toMap(),
    };

  @override
  factory RectangleFeature.from(Map<String, dynamic> item) {
    return RectangleFeature(
      type: item['type'] as DrawFeatureType,
      strokeColor: Color(item['strokeColor'] as int),
      fillColor: Color(item['fillColor'] as int),
      width: item['width'] as double,
      leftTop: item['leftTop'] as Point,
      rightBottom: item['rightBottom'] as Point,
    );
  }

  @override
  bool operator==(Object other) =>
   identical(this, other) ||
   other is RectangleFeature && runtimeType == other.runtimeType &&
   super.type == other.type &&
   strokeColor == other.strokeColor &&
   fillColor == other.fillColor &&
   width == other.width &&
   style == other.style &&
   leftTop == other.leftTop &&
   rightBottom == other.rightBottom;

  @override
  int get hashCode => runtimeType.hashCode ^ super.hashCode ^ strokeColor.hashCode ^ fillColor.hashCode ^ width.hashCode;
}

class LabelFeature extends DrawingFeature {
  final String text;
  final Color color;
  final Point position;

  LabelFeature({
    super.type = DrawFeatureType.label,
    required this.text,
    this.color = Colors.black,
    required this.position});

  LabelFeature copyWith(String? text, Color? color, Point? position) {
    return LabelFeature(
      type: type,
      text: text ?? this.text,
      color: color ?? this.color,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    "type": type.name,
    "text": text,
    "color": color.toARGB32(),
    "position": position.toMap(),
  };

  @override
  factory LabelFeature.from(Map<String, dynamic> item) {
    return LabelFeature(
      type: item['type'] as DrawFeatureType,
      text: item['text'] as String,
      color: Color(item['color'] as int),
      position: item['position'] as Point,
    );
  }

  @override
  bool operator==(Object other) =>
    identical(this, other) ||
    other is LabelFeature && runtimeType == other.runtimeType &&
    text.compareTo(other.text) == 0 &&
    color == other.color &&
    position == other.position;

  @override
  int get hashCode => runtimeType.hashCode ^ super.hashCode ^ text.hashCode ^ color.hashCode ^ position.hashCode;
}

extension on Point<num> {
  Map<String, num> toMap() => {
    'x': x,
    'y': y,
  };
}