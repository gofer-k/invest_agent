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
    visibleStart = startDatetime(periodType, domain.last) ?? minDomainStart;
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

    final currentSpan = visibleSpan;
    final newSpan = currentSpan * (1 / factor);
    if (newSpan <= initialSpan) {
      final mid = visibleStart.add(currentSpan ~/ 2);
      visibleStart = mid.subtract(newSpan ~/ 2);
      visibleEnd = mid.add(newSpan ~/ 2);
      notifyListeners();
    }
  }
}
