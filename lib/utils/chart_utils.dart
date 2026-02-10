import 'package:invest_agent/model/analysis_respond.dart';

import '../model/analysis_period.dart';
import 'custom_datetime_format.dart';

double valueToPos({required double currValue, required double min,
  required double max, required double height}) {
  final range = max - min;
  if (range == 0) return height /2;

  final ratio = (currValue - min) / range;
  return height * (1 - ratio);
}

double dateToPos(DateTime curr, DateTime start, DateTime end, double width) {
  final total = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  if (total == 0) return 0;

  final currOffset = curr.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  final ratio = currOffset / total;

  return ratio * width;
}

DateTime posToDate(double x, DateTime start, DateTime end, double width) {
  final total = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  final ratio = x / width;
  final ms = start.millisecondsSinceEpoch + (ratio * total).round();
  return DateTime.fromMillisecondsSinceEpoch(ms);
}

// int findNearestIndex(DateTime target, List<Tt extends BaseIndicatorValue> data) {
int findNearestIndex(DateTime startDate, DateTime target, List<BaseIndicatorValue> data) {
  int low = 0;
  int high = data.length - 1;
  // final int firstVisibleIndex = data.indexWhere(
  //       (price) => !price.dateTime.isBefore(startDate),
  // );
  while (low < high) {
    final mid = (low + high) >> 1;
    final midTime = data[mid].dateTime;

    if (midTime.isBefore(target)) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }

  // low is the first >= target
  if (low == 0) return 0;

  final prev = data[low - 1];
  final curr = data[low];

  final diffPrev = (prev.dateTime.millisecondsSinceEpoch - target.millisecondsSinceEpoch).abs();
  final diffCurr = (curr.dateTime.millisecondsSinceEpoch - target.millisecondsSinceEpoch).abs();

  return diffPrev < diffCurr ? low - 1 : low;
}

DateTime? startDatetime(PeriodType period, DateTime endDate) {
  return switch(period) {
    PeriodType.yTd => DateTime(endDate.year, 1, 1),
    PeriodType.week => endDate.subtract(const Duration(days: weekDays)),
    PeriodType.month => endDate.subtract(const Duration(days: monthDays)),
    PeriodType.quaterYear =>
        endDate.subtract(const Duration(days: monthDays * 3)),
    PeriodType.halfYear =>
        endDate.subtract(const Duration(days: monthDays * 6)),
    PeriodType.year => endDate.subtract(const Duration(days: yearDays)),
    PeriodType.twoYears =>
        endDate.subtract(const Duration(days: yearDays * 2)),
    PeriodType.threeYears =>
        endDate.subtract(const Duration(days: yearDays * 3)),
    PeriodType.fiveYears =>
        endDate.subtract(const Duration(days: yearDays) * 5),
    PeriodType.max => null,
  };
}

Duration? periodSpan(PeriodType period) {
  final currTime = DateTime.now();
  return switch(period) {
    PeriodType.yTd => currTime.difference(DateTime(currTime.year, 1, 1)),
    PeriodType.week => const Duration(days: weekDays),
    PeriodType.month => const Duration(days: monthDays),
    PeriodType.quaterYear => const Duration(days: monthDays * 3),
    PeriodType.halfYear => const Duration(days: monthDays * 6),
    PeriodType.year => const Duration(days: yearDays),
    PeriodType.twoYears => const Duration(days: yearDays * 2),
    PeriodType.threeYears => const Duration(days: yearDays * 3),
    PeriodType.fiveYears => const Duration(days: yearDays * 5),
    PeriodType.max => null,
  };
}

void drawDatetimeIndicateLine(DateTime startDate, DateTime endDate, DateTime currTime, void Function(DateTime newTime) drawDatetimeDomain) {
  final step = CustomDatetimeFormat.span(startDate, endDate, currTime);
  while (currTime.isBefore(endDate)) {
    drawDatetimeDomain(currTime);
    currTime = currTime.add(step);
  }
}
