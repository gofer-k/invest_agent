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