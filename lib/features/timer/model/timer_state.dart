import 'package:soonmodoro/entities/session/model/session.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';

/// 타이머 화면의 전체 상태.
///
/// 통계는 필드로 두지 않고 [sessions]에서 파생한다. 카운터를 각각 증가시키면
/// 서로 어긋날 수 있지만, 하나의 목록에서 계산하면 그럴 여지가 없다.
class TimerState {
  final TimerMode mode;
  final Duration remaining;
  final bool isRunning;

  /// 긴 휴식까지 남은 집중 사이클 진행도. 0~4.
  final int cycleCount;

  final List<Session> sessions;

  const TimerState({
    required this.mode,
    required this.remaining,
    required this.isRunning,
    required this.cycleCount,
    required this.sessions,
  });

  /// 집중 모드로 대기 중인 초기 상태.
  factory TimerState.initial(Duration focusDuration) => TimerState(
    mode: TimerMode.focus,
    remaining: focusDuration,
    isRunning: false,
    cycleCount: 0,
    sessions: const [],
  );

  int get completedFocusCount => sessions.where((s) => s.isFocus).length;

  /// 완료된 집중 세션의 총 시간. 진행 중인 세션은 포함하지 않는다.
  Duration get totalFocusTime => sessions
      .where((s) => s.isFocus)
      .fold(Duration.zero, (sum, s) => sum + s.duration);

  TimerState copyWith({
    TimerMode? mode,
    Duration? remaining,
    bool? isRunning,
    int? cycleCount,
    List<Session>? sessions,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      cycleCount: cycleCount ?? this.cycleCount,
      sessions: sessions ?? this.sessions,
    );
  }
}
