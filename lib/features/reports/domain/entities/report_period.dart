enum ReportPeriod {
  today,
  week,
  month;

  DateTime startAt(DateTime now) => switch (this) {
        ReportPeriod.today => DateTime(now.year, now.month, now.day),
        ReportPeriod.week => now.subtract(const Duration(days: 7)),
        ReportPeriod.month => DateTime(now.year, now.month, 1),
      };
  DateTime endBefore(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1);
}
