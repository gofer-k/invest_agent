import 'package:flutter/material.dart';

class DateTimeLabel {
  final Color textColor;
  final Color backgroundColor;
  final double alpha;
  final double fontSize;
  final DateTime time;
  final Offset position;

  DateTimeLabel({
    required this.time,
    required this.position,
    this.textColor = Colors.white70,
    this.backgroundColor = Colors.transparent,
    this.alpha = 1.0,
    this.fontSize = 12.0,
  });
}

class ValueLabel {
  final Color textColor;
  final Color backgroundColor;
  final double alpha;
  final double fontSize;
  final double value;
  final Offset position;

  ValueLabel({
    required this.value,
    required this.position,
    this.textColor = Colors.white70,
    this.backgroundColor = Colors.transparent,
    this.alpha = 1.0,
    this.fontSize = 12.0,
  });
}
