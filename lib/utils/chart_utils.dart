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
  final spanDays = end.difference(start).inDays;
  final ratio = curr.difference(start).inDays / spanDays;
  return ratio * width;
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
