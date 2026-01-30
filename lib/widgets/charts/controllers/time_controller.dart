import 'package:flutter/foundation.dart';

class TimeController extends ChangeNotifier {
  DateTime visibleStart;
  DateTime visibleEnd;
  DateTime minDomainStart;
  DateTime maxDomainEnd;
  final List<DateTime> domain;

  TimeController({required this.domain,
  }) : minDomainStart = domain.first, maxDomainEnd = domain.last,
        visibleStart = domain.first, visibleEnd = domain.last;

  Duration get visibleSpan => visibleEnd.difference(visibleStart);
  Duration get initialSnap => maxDomainEnd.difference(minDomainStart);

  void pan(Duration delta) {
    // final newEnd = domain.firstWhere((element) => element.isAfter(visibleEnd.add(delta)));
    // final newStart = domain.firstWhere((element) => element.isAfter(visibleStart.add(delta)));

    final newEnd = visibleEnd.add(delta);
    final newStart = visibleStart.add(delta);

    // clamp to data bounds
    if (newStart.isBefore(minDomainStart)) {
      visibleStart = minDomainStart;
      visibleEnd = minDomainStart.add(visibleSpan);
    }
    else if (newEnd.isAfter(maxDomainEnd)) {
      visibleEnd = maxDomainEnd;
      visibleStart = maxDomainEnd.subtract(visibleSpan);
    }
    else {
      visibleStart = newStart;
      visibleEnd = newEnd;
    }
    notifyListeners();
  }

  void zoom(double factor, DateTime? anchor) {
    if (factor == 1.0)  return;

    final currentSpan = visibleSpan;
    final newSpan = currentSpan * (1 / factor);
    if (newSpan <= initialSnap) {
      final mid = visibleStart.add(currentSpan ~/ 2);
      visibleStart = mid.subtract(newSpan ~/ 2);
      visibleEnd = mid.add(newSpan ~/ 2);
      notifyListeners();
    }
  }

  // void updateDomain(DateTime newStart, DateTime newEnd) {
  //   // final newStartIndex = startIndex + (visibleSpan.inDays) ~/ 2;
  //   // final newEndIndex = endIndex - (visibleSpan.inDays) ~/ 2;
  //   // final newStart = newStartIndex >= 0 ? domain[newStartIndex] : visibleStart;
  //   // final newEnd = newEndIndex >= 0 ? domain[newEndIndex] : visibleEnd;
  //
  //   // clamp
  //   DateTime clampedStart = newStart;
  //   DateTime clampedEnd = newEnd;
  //
  //   if (clampedStart.isBefore(minDomainStart)) {
  //     clampedStart = minDomainStart;
  //     clampedEnd = minDomainStart.add(newSpan);
  //   }
  //   if (clampedEnd.isAfter(maxDomainEnd)) {
  //     clampedEnd = maxDomainEnd;
  //     clampedStart = maxDomainEnd.subtract(newSpan);
  //   }
  //
  //   visibleStart = clampedStart;
  //   visibleEnd = clampedEnd;
  //   notifyListeners();
  // }

  double dataTimePerPos (double currVal, double width) {
    return (currVal / (width - 1)).clamp(0.0, 1.0);
  }

  DateTime? offsetDomainDay(int currIndex, double ratio, double span) {
    final targetIndex = (currIndex + (span * ratio)).round();
    return targetIndex >= 0 ? domain[targetIndex] : null;
  }

  // DateTime? pixelToDomain(double pixelX) {
  //   final ratio = dataTimePerPos(pixelX);
  //   final startIndex = domain.indexOf(visibleStart);
  //   return offsetDomainDay(startIndex, ratio, visibleSpan.inDays as double) ?? visibleStart;
  // }
  // double domainToPixel(DateTime currData, Size size) {
  //   final currIndex = domain.indexOf(currData);
  //   final startIndex = domain.indexOf(visibleStart);
  //   final ratio = dataTimePerPos(currIndex - startIndex, size);
  //
  //   final t = ((domainX - _minX) / windowWidth);
  //   return t * width;
  // }
}
