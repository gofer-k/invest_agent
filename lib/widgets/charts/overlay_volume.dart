import 'package:flutter/material.dart';
import 'package:invest_agent/widgets/charts/overlay_chart.dart';

import '../../model/chart_style.dart';
import '../../model/results/indicator/price_result.dart';

class OverlayVolume extends OverlayChart {
  final List<IndexPriceItem> data;
  final Color upVolumeColor;
  final Color downVolumeColor;
  final double barWidth;

  OverlayVolume({
    super.overlayType = OverlayType.volume,
    super.chartStyle = ChartStyle.bars,
    required this.data,
    this.upVolumeColor = Colors.green,
    this.downVolumeColor = Colors.redAccent,
    this.barWidth = 3.0
  });

  @override
  void draw(Canvas canvas, Size size, OverlayContext ctx) {
    if (data.isEmpty) return;

    final visibleData = data.where((p) => !p.dateTime.isBefore(ctx.startDate) && !p.dateTime.isAfter(ctx.endDate)).toList();
    if (visibleData.isEmpty) return;

    double maxVolume = visibleData
        .map((e) => e.volume)
        .reduce((current, next) => current > next ? current : next);

    if (maxVolume == 0) return;

    final paintUp = Paint()
      ..color = upVolumeColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    final paintDown = Paint()
      ..color = downVolumeColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.butt;

    for (final price in visibleData) {
      final x = ctx.dateToPos(price.dateTime, size);
      final vol = price.volume;
      final barHeight = (vol / maxVolume) * size.height * 0.75;
      final yTop = size.height - barHeight;
      final yBottom = size.height;

      canvas.drawLine(
        Offset(x, yTop),
        Offset(x, yBottom),
        vol > 0 ? paintUp : paintDown,
      );
    }
  }
}
