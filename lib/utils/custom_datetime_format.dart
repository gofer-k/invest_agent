import '../model/analysis_period.dart';

class CustomDatetimeFormat {
  static Duration span(DateTime startDate, DateTime endDate, DateTime currTime) {
    final span = endDate.difference(startDate);
    if(span.inDays > twiceYearDays) {
      return Duration(days: yearDays);
    }
    else if (span.inDays > twiceMonthDays) {
      return Duration(days: monthDays);
    }
    else if(span.inDays > twiceWeekDays) {
      return Duration(days: weekDays);
    }
    return Duration(days: 1);
  }

  static String format(DateTime currTime, Duration span) {
    if (span.inDays > twiceYearDays) return "${currTime.year}";
    if (span.inDays > twiceMonthDays) return CustomDatetimeFormat.monthShort(currTime.month);
    if (span.inDays > twiceWeekDays) {
      return "${CustomDatetimeFormat.monthShort(currTime.month)}/${currTime.day}";
    }
    return "${CustomDatetimeFormat.monthShort(currTime.month)}/${currTime.day}";
  }

  static String monthShort(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}