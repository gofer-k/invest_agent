class CustomDatetimeFormat {
  static const int yearDays = 365;
  static const int monthDays = 30;
  static const int weekDays = 7;
  static const int twiceYearDays = yearDays * 2;
  static const int twiceMonthDays = monthDays * 2;
  static const int twiceWeekDays = weekDays * 2;

  static Duration span(DateTime startDate, DateTime endDate, DateTime currTime) {
    final span = endDate.difference(startDate);
    if(span.inDays > CustomDatetimeFormat.twiceYearDays) {
      return Duration(days: CustomDatetimeFormat.yearDays);
    }
    else if (span.inDays > CustomDatetimeFormat.twiceMonthDays) {
      return Duration(days: CustomDatetimeFormat.monthDays);
    }
    else if(span.inDays > CustomDatetimeFormat.twiceWeekDays) {
      return Duration(days: CustomDatetimeFormat.weekDays);
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