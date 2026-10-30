import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';

/// 완료된 타이머 세션 한 건.
///
/// 완료 세션 수·집중 시간 같은 통계는 이 목록에서 파생한다. 카운터를 따로
/// 관리하지 않으므로 값끼리 어긋날 수 없다.
class Session {
  final int? id;
  final TimerMode mode;
  final DateTime startedAt;
  final DateTime endedAt;

  const Session({
    this.id,
    required this.mode,
    required this.startedAt,
    required this.endedAt,
  });

  Duration get duration => endedAt.difference(startedAt);

  bool get isFocus => mode == TimerMode.focus;

  Map<String, Object?> toRow() {
    return {
      if (id != null) 'id': id,
      'mode': mode.name,
      'started_at': startedAt.millisecondsSinceEpoch,
      'ended_at': endedAt.millisecondsSinceEpoch,
    };
  }

  factory Session.fromRow(Map<String, Object?> row) {
    return Session(
      id: row['id'] as int,
      mode: TimerMode.values.byName(row['mode'] as String),
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['started_at'] as int),
      endedAt: DateTime.fromMillisecondsSinceEpoch(row['ended_at'] as int),
    );
  }

  Session copyWith({
    int? id,
    TimerMode? mode,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Session(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
