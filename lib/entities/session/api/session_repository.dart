import 'package:soonmodoro/entities/session/api/session_dao.dart';
import 'package:soonmodoro/entities/session/model/daily_stat.dart';
import 'package:soonmodoro/entities/session/model/session.dart';
import 'package:soonmodoro/entities/session/model/statistics_summary.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_durations.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class SessionRepository {
  Future<Session> add(Session session);
  Future<StatisticsSummary> loadSummary({int recentDays});
  Future<DailyStat> loadDay(DateTime date);
}

class RealSessionRepository implements SessionRepository {
  late final SessionDao _dao;

  RealSessionRepository() {
    init();
  }

  Future<void> init() async {
    var db = await openDatabase('');
    _dao = SessionDao(db: db);
  }

  @override
  Future<Session> add(Session session) async {
    final id = await _dao.insert(session.toRow());

    return session.copyWith(id: id);
  }

  @override
  Future<DailyStat> loadDay(DateTime date) async {
    final rows = await _dao.queryByDateRange(
      date.millisecondsSinceEpoch,
      date.millisecondsSinceEpoch,
    );
    final sessions = rows.map(Session.fromRow).toList();

    return DailyStat(
      date: date,
      sessionCount: rows.length,
      focusTime: getTotalFocusTime(sessions),
    );
  }

  Duration getTotalFocusTime(List<Session> sessions) => sessions
      .map((e) => e.duration)
      .fold(Duration.zero, (prev, cur) => prev + cur);

  Future<List<DailyStat>> getRecentDays() async {
    // 일자별로 group화 시키기
    List<DailyStat> result = [];
    for (var i = 7; i >= 0; i--) {
      var date = DateTime.now().subtract(Duration(days: i));

      var dailyStat = await loadDay(date);

      result.add(dailyStat);
    }

    return result;
  }

  @override
  Future<StatisticsSummary> loadSummary({int recentDays = 7}) async {
    final rows = await _dao.queryAll();
    final sessions = rows.map(Session.fromRow).toList();
    final recentDays = await getRecentDays();

    return StatisticsSummary(
      totalSessions: sessions.length,
      totalFocusTime: getTotalFocusTime(sessions),
      currentStreak: 0,
      recentDays: recentDays,
      today: DailyStat.initial(),
    );
  }
}
