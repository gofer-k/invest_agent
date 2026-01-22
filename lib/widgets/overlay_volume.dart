import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/chart_overlay.dart';

import '../model/analysis_respond.dart';

class OverlayVolume extends ChartOverlay {
  final List<PriceData> priceData;
  final Color upVolumeColor;
  final Color downVolumeColor;
  final double barWidth;

  OverlayVolume({required this.priceData,
    this.upVolumeColor = Colors.green,
    this.downVolumeColor = Colors.redAccent,
    this.barWidth = 3.0});

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (priceData.isEmpty) return;
    double maxVolume = priceData.reduce((current, next) => current.volume > next.volume ? current : next).volume;

    final paintUp = Paint()
      ..color = upVolumeColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final paintDown = Paint()
      ..color = downVolumeColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    for (var price in priceData) {
      if (price.dateTime.isBefore(ctx.startDate) || price.dateTime.isAfter(ctx.endDate)) {
        continue;
      }
      final x = ctx.dateToPos(price.dateTime, size);
      final vol = price.volume;
      final barHeight = (vol / maxVolume) * size.height * 0.5;
      final yTop = size.height - barHeight;
      final yBottom = size.height;

      canvas.drawLine(Offset(x, yTop), Offset(x, yBottom), vol > 0 ? paintUp : paintDown);
    }
  }
  
}