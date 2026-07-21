import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';

/// 완료된 타이머 세션 한 건.
///
/// 완료 세션 수·집중 시간 같은 통계는 이 목록에서 파생한다. 카운터를 따로
/// 관리하지 않으므로 값끼리 어긋날 수 없다.
class Session {
  final TimerMode mode;
  final DateTime startedAt;
  final DateTime endedAt;

  const Session({
    required this.mode,
    required this.startedAt,
    required this.endedAt,
  });

  Duration get duration => endedAt.difference(startedAt);

  bool get isFocus => mode == TimerMode.focus;
}
