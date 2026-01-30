enum PeriodType {
  yTd('YTD'),
  week('1w'),
  month('1m'),
  quaterYear('3m'),
  halfYear('6m'),
  year('1y'),
  twoYears('2y'),
  threeYears('3y'),
  fiveYears('5y'),
  max('max');

  const PeriodType(this.value);
  final String value;

  @override
  String toString() => value;
}

const int yearDays = 365;
const int monthDays = 30;
const int weekDays = 7;
const int twiceYearDays = yearDays * 2;
const int twiceMonthDays = monthDays * 2;
const int twiceWeekDays = weekDays * 2;
