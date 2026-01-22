import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

bool beginYearDay(int currentIndex, DateTime dt, List<DateTime> times) {
  if (currentIndex > 0) {
    final previousDay = times[currentIndex - 1];
    return previousDay.year != dt.year;
  }
  return false;
}

bool beginMonth(int currentIndex, DateTime dt, List<DateTime> times) {
  if (currentIndex > 0) {
    final previousDay = times[currentIndex - 1];
    return previousDay.month != dt.month;
  }
  return false;
}

Widget buildDateLabel(
    double value,
    TitleMeta meta,
    double windowWidth,
    List<DateTime> times,
    ) {
  int index = value.round();
  if (index < 0 || index >= times.length) {
    return const SizedBox.shrink();
  }

  final dt = times[index];

  // -------------------------------
  // 1. FULLY ZOOMED OUT MODE
  // -------------------------------
  // Show years + quarterly months
  if (windowWidth > 400) {
    // Show YEAR at the beginning of year
    if (beginYearDay(index, dt,times)) {
      return Text(
        dt.year.toString(),
        style: const TextStyle(fontSize: 11, color: Colors.white70),
      );
    }

    // Show QUARTERLY months (Jan, Apr, Jul, Oct)
    if (beginMonth(index, dt, times) && (dt.month == 1 || dt.month == 4 || dt.month == 7 || dt.month == 10)) {
      return Text(
        _monthShort(dt.month),
        style: const TextStyle(fontSize: 10, color: Colors.white54),
      );
    }

    return const SizedBox.shrink();
  }

  // -------------------------------
  // 2. MEDIUM ZOOM MODE
  // -------------------------------
  // Show months + years
  if (windowWidth > 60) {
    // Show YEAR at te beginning of year
    if (beginYearDay(index, dt,times)) {
      return Text(
        dt.year.toString(),
        style: const TextStyle(fontSize: 11, color: Colors.white70),
      );
    }

    // Show MONTH at the beginning of each month
    if (beginMonth(index, dt, times)) {
      return Text(
        _monthShort(dt.month),
        style: const TextStyle(fontSize: 10, color: Colors.white54),
      );
    }

    return const SizedBox.shrink();
  }

  // -------------------------------
  // 3. CLOSE ZOOM MODE
  // -------------------------------
  // Show Month/day (e.g., "Mar 12")
  return Text(
    "${_monthShort(dt.month)} ${dt.day}",
    style: const TextStyle(fontSize: 10, color: Colors.white54),
  );
}

String _monthShort(int m) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[m];
}

