import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/entities/session/model/session.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_durations.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';
import 'package:soonmodoro/features/alarm/model/alarm_controller.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';
import 'package:soonmodoro/features/timer/model/timer_state.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

/// 디버그 빌드에서는 짧은 시간을 쓴다. 테스트는 이 provider를 override해서
/// 실제 25분 동작을 검증할 수 있다.
final timerDurationsProvider = Provider<TimerDurations>(
  (ref) => kDebugMode ? TimerDurations.debug() : TimerDurations.real(),
);

/// 긴 휴식이 나오기까지 필요한 집중 사이클 수.
const _longBreakLimit = 4;

class TimerViewModel extends Notifier<TimerState> {
  StreamSubscription<void>? _subscription;

  /// 현재 구간이 끝나는 벽시계 시각.
  DateTime? _endsAt;

  /// 현재 구간이 시작된 벽시계 시각. 완료 시 [Session]에 기록한다.
  DateTime? _startedAt;

  TimerDurations get _durations => ref.read(timerDurationsProvider);
  AlarmController get _alarm => ref.read(alarmControllerProvider);
  HapticService get _haptic => ref.read(hapticServiceProvider);

  @override
  TimerState build() {
    ref.onDispose(_cancelTicks);
    return TimerState.initial(_durations.of(TimerMode.focus));
  }

  void start() {
    if (state.isRunning) return;

    _haptic.tap();
    _alarm.stop();

    final now = clock.now();
    final remaining = state.remaining > Duration.zero
        ? state.remaining
        : _durations.of(state.mode);

    _startedAt = now;
    _endsAt = now.add(remaining);

    _cancelTicks();
    _subscription = Stream<void>.periodic(
      const Duration(seconds: 1),
    ).listen((_) => _onTick());

    state = state.copyWith(remaining: remaining, isRunning: true);
  }

  void pause() {
    if (!state.isRunning) return;

    _haptic.tap();
    _alarm.stop();
    _cancelTicks();

    state = state.copyWith(remaining: _timeLeft(), isRunning: false);
  }

  void toggle() => state.isRunning ? pause() : start();

  /// 집중 모드로 되돌린다. 누적 세션 기록은 유지한다.
  void reset() {
    _alarm.stop();
    _cancelTicks();
    _startedAt = null;
    _endsAt = null;

    state = state.copyWith(
      mode: TimerMode.focus,
      remaining: _durations.of(TimerMode.focus),
      isRunning: false,
      cycleCount: 0,
    );
  }

  void selectMode(TimerMode mode) {
    _alarm.stop();
    _cancelTicks();
    _startedAt = null;
    _endsAt = null;

    state = state.copyWith(
      mode: mode,
      remaining: _durations.of(mode),
      isRunning: false,
    );
  }

  /// 남은 시간을 벽시계로 계산한다.
  ///
  /// 틱 횟수를 세지 않는 이유: [Stream.periodic]은 N초에 정확히 N번을 보장하지
  /// 않고 밀린 만큼 몰아서 쏘지도 않는다. 틱을 세면 타이머가 실제보다 길어진다.
  /// 틱은 화면 갱신 신호로만 쓰고 시간의 근거는 벽시계에 둔다.
  Duration _timeLeft() {
    final endsAt = _endsAt;
    if (endsAt == null) return state.remaining;

    final left = endsAt.difference(clock.now());
    return left.isNegative ? Duration.zero : left;
  }

  void _onTick() {
    final left = _timeLeft();
    if (left > Duration.zero) {
      state = state.copyWith(remaining: left);
      return;
    }
    _complete();
  }

  /// 구간 완료 처리.
  ///
  /// 구독 해제 → 세션 기록 → 모드 전환까지가 동기라 재진입이 불가능하다.
  /// 알람만 마지막에 비동기로 띄운다.
  void _complete() {
    _cancelTicks();

    final now = clock.now();
    final finishedMode = state.mode;
    final sessions = finishedMode == TimerMode.focus
        ? [
            ...state.sessions,
            Session(
              mode: finishedMode,
              startedAt: _startedAt ?? now,
              endedAt: now,
            ),
          ]
        : state.sessions;

    final cycleCount = switch (finishedMode) {
      TimerMode.focus => state.cycleCount + 1,
      TimerMode.longBreak => 0,
      TimerMode.shortBreak => state.cycleCount,
    };

    final nextMode = switch (finishedMode) {
      TimerMode.focus =>
        cycleCount % _longBreakLimit == 0
            ? TimerMode.longBreak
            : TimerMode.shortBreak,
      _ => TimerMode.focus,
    };

    _startedAt = null;
    _endsAt = null;

    state = state.copyWith(
      mode: nextMode,
      remaining: _durations.of(nextMode),
      isRunning: false,
      cycleCount: cycleCount,
      sessions: sessions,
    );

    if (finishedMode == TimerMode.focus) {
      _alarm.ring();
    }
  }

  void _cancelTicks() {
    _subscription?.cancel();
    _subscription = null;
  }
}

final timerViewModel = NotifierProvider<TimerViewModel, TimerState>(
  TimerViewModel.new,
);
