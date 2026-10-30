import 'package:soonmodoro/entities/session/model/daily_stat.dart';

class StatisticsSummary {
  final int totalSessions;
  final Duration totalFocusTime;
  final int currentStreak;
  final List<DailyStat> recentDays;
  final DailyStat today;

  StatisticsSummary({
    required this.totalSessions,
    required this.totalFocusTime,
    required this.currentStreak,
    required this.recentDays,
    required this.today,
  });

  factory StatisticsSummary.initial() {
    return StatisticsSummary(
      totalSessions: 0,
      totalFocusTime: Duration.zero,
      currentStreak: 0,
      recentDays: [],
      today: DailyStat.initial(),
    );
  }
}
