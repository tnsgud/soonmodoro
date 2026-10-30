class DailyStat {
  final DateTime date;
  final int sessionCount;
  final Duration focusTime;

  DailyStat({
    required this.date,
    required this.sessionCount,
    required this.focusTime,
  });

  factory DailyStat.initial() {
    return DailyStat(
      date: DateTime.now(),
      sessionCount: 0,
      focusTime: Duration.zero,
    );
  }
}
