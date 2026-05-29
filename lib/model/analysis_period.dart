enum PeriodType {
  yTd('YTD', -1),
  week('1w', 1),
  month('1m', monthDays ),
  quaterYear('3m', 3 * monthDays),
  halfYear('6m', 6 * monthDays),
  year('1y', yearDays),
  twoYears('2y', twiceYearDays),
  threeYears('3y', 3 * yearDays),
  fiveYears('5y', 5 * yearDays),
  max('max', -2);

  const PeriodType(this.value, this.days);
  final String value;
  final int days;

  @override
  String toString() => value;
}

const int yearDays = 365;
const int monthDays = 30;
const int weekDays = 7;
const int twiceYearDays = yearDays * 2;
const int twiceMonthDays = monthDays * 2;
const int twiceWeekDays = weekDays * 2;
