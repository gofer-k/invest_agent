import 'package:flutter/foundation.dart';
import 'package:invest_agent/model/analysis_period.dart';

import '../../../utils/chart_utils.dart';

class TimeController extends ChangeNotifier {
  late DateTime visibleStart;
  late DateTime visibleEnd;
  DateTime minDomainStart;
  DateTime maxDomainEnd;
  PeriodType  periodType;
  final List<DateTime> domain;

  TimeController({required this.periodType, required this.domain})
      : minDomainStart = domain.first, maxDomainEnd = domain.last {
    final start = startDatetime(periodType, maxDomainEnd) ?? minDomainStart;
    visibleStart = start.isBefore(minDomainStart) ? minDomainStart : start;
    visibleEnd = maxDomainEnd;
  }

  Duration get visibleSpan => visibleEnd.difference(visibleStart);
  Duration get initialSpan => periodSpan(periodType) ?? maxDomainEnd.difference(minDomainStart);

  void pan(Duration delta) {
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

      final currentSpan = visibleSpan.inMilliseconds;
      final newSpan = Duration(milliseconds: (currentSpan * (1 / factor)).round()); // Assuming rounding is desired for double result
      if (newSpan <= initialSpan) {
        final mid = visibleStart.add(visibleSpan ~/ 2);
        final halfNewSpan = newSpan ~/ 2;
        visibleStart = mid.subtract(halfNewSpan);
        visibleEnd = mid.add(halfNewSpan);
        notifyListeners();
      }
    }
}
