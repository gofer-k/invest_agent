import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:invest_agent/widgets/datetime_label.dart';

List<VerticalLine> buildDateVerticalLines({
  required List<DateTime> times,
  required List<double> domainX,
  required double minX,
  required double maxX,
}) {
  final List<VerticalLine> lines = [];

  for (int i = 0; i < times.length; i++) {
    final x = domainX[i];
    if (x < minX || x > maxX) continue; // skip if outside visible window

    final dt = times[i];

    // ---- YEAR BOUNDARY ----
    if (beginYearDay(i, dt, times)) {
      lines.add(
        VerticalLine(
          x: x,
          color: const Color(0x55FFFFFF),
          strokeWidth: 1.0,
          // dashArray: [4, 4],
        ),
      );
      continue;
    }

    // ---- MONTH BOUNDARY ----
    if (beginMonth(i, dt, times) && (dt.month == 4 || dt.month == 7 || dt.month == 10)) {
      lines.add(
        VerticalLine(
          x: x,
          color: const Color(0x33FFFFFF),
          strokeWidth: 0.6,
          dashArray: [3, 3],
        ),
      );
    }
  }

  return lines;
}
