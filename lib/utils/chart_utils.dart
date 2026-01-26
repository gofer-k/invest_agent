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

void drawDatetimeIndicateLine(DateTime startDate, DateTime endDate, DateTime currTime, void Function(DateTime newTime) drawDatetimeDomain) {
  final step = CustomDatetimeFormat.span(startDate, endDate, currTime);
  while (currTime.isBefore(endDate)) {
    drawDatetimeDomain(currTime);
    currTime = currTime.add(step);
  }
}
