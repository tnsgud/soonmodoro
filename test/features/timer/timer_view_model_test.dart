import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_durations.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';
import 'package:soonmodoro/features/timer/model/timer_state.dart';
import 'package:soonmodoro/features/timer/view_model/timer_view_model.dart';

import '../../support/fake_services.dart';

const focusDuration = Duration(minutes: 25);
const shortBreakDuration = Duration(minutes: 5);
const longBreakDuration = Duration(minutes: 15);

/// 디버그 빌드에서도 실제 시간으로 검증한다.
ProviderContainer buildContainer({
  FakeAudioService? audio,
  FakeHapticService? haptic,
}) {
  // 값이 아니라 팩토리를 대체한다. audioServiceProvider를 통째로 갈아끼우면
  // 본문의 초기화 호출과 ref.onDispose 등록이 실행되지 않는다.
  final audioService = audio ?? FakeAudioService();
  final hapticService = haptic ?? FakeHapticService();

  return ProviderContainer(
    overrides: [
      timerDurationsProvider.overrideWithValue(
        const TimerDurations(
          focus: focusDuration,
          shortBreak: shortBreakDuration,
          longBreak: longBreakDuration,
        ),
      ),
      audioServiceFactoryProvider.overrideWithValue(() => audioService),
      hapticServiceFactoryProvider.overrideWithValue(() => hapticService),
    ],
  );
}

void main() {
  group('초기 상태', () {
    test('집중 모드로 대기하며 통계는 0이다', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final state = container.read(timerViewModel);

      expect(state.mode, TimerMode.focus);
      expect(state.remaining, focusDuration);
      expect(state.isRunning, isFalse);
      expect(state.completedFocusCount, 0);
      // 세션이 비어 있을 때 합계가 터지지 않아야 한다.
      expect(state.totalFocusTime, Duration.zero);
    });
  });

  group('시간 계산', () {
    test('남은 시간은 벽시계 기준으로 줄어든다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);

        container.read(timerViewModel.notifier).start();
        async.elapse(const Duration(minutes: 10));

        expect(
          container.read(timerViewModel).remaining,
          const Duration(minutes: 15),
        );
      });
    });

    test('중지하면 남은 시간이 그 시점에 멈춘다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.start();
        async.elapse(const Duration(minutes: 10));
        viewModel.pause();
        async.elapse(const Duration(minutes: 10));

        final state = container.read(timerViewModel);
        expect(state.isRunning, isFalse);
        expect(state.remaining, const Duration(minutes: 15));
      });
    });
  });

  group('세션 완료', () {
    test('집중이 끝나면 짧은 휴식으로 넘어가고 세션이 기록된다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);

        container.read(timerViewModel.notifier).start();
        async.elapse(focusDuration);

        final state = container.read(timerViewModel);
        expect(state.mode, TimerMode.shortBreak);
        expect(state.remaining, shortBreakDuration);
        expect(state.isRunning, isFalse);
        expect(state.cycleCount, 1);
        expect(state.completedFocusCount, 1);
        expect(state.totalFocusTime, focusDuration);
      });
    });

    test('완료 후 시간이 더 흘러도 세션이 중복 기록되지 않는다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);

        container.read(timerViewModel.notifier).start();
        async.elapse(focusDuration + const Duration(minutes: 5));

        expect(container.read(timerViewModel).completedFocusCount, 1);
      });
    });

    test('휴식은 세션으로 기록되지 않는다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.selectMode(TimerMode.shortBreak);
        viewModel.start();
        async.elapse(shortBreakDuration);

        final state = container.read(timerViewModel);
        expect(state.completedFocusCount, 0);
        expect(state.totalFocusTime, Duration.zero);
        expect(state.mode, TimerMode.focus);
      });
    });

    test('집중 4회를 채우면 긴 휴식으로 넘어간다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        for (var i = 0; i < 4; i++) {
          viewModel.selectMode(TimerMode.focus);
          viewModel.start();
          async.elapse(focusDuration);
        }

        final state = container.read(timerViewModel);
        expect(state.mode, TimerMode.longBreak);
        expect(state.cycleCount, 4);
        expect(state.completedFocusCount, 4);
        expect(state.totalFocusTime, focusDuration * 4);
      });
    });

    test('집중 3회까지는 짧은 휴식으로 간다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        for (var i = 0; i < 3; i++) {
          viewModel.selectMode(TimerMode.focus);
          viewModel.start();
          async.elapse(focusDuration);
        }

        expect(container.read(timerViewModel).mode, TimerMode.shortBreak);
      });
    });
  });

  group('알람', () {
    test('집중 완료 시 소리와 진동이 울린다', () {
      fakeAsync((async) {
        final audio = FakeAudioService();
        final haptic = FakeHapticService();
        final container = buildContainer(audio: audio, haptic: haptic);
        addTearDown(container.dispose);

        container.read(timerViewModel.notifier).start();
        async.elapse(focusDuration);
        async.flushMicrotasks();

        expect(audio.playCount, 1);
        expect(haptic.alarmCount, 1);
      });
    });

    test('휴식 완료 시에는 울리지 않는다', () {
      fakeAsync((async) {
        final audio = FakeAudioService();
        final haptic = FakeHapticService();
        final container = buildContainer(audio: audio, haptic: haptic);
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.selectMode(TimerMode.shortBreak);
        viewModel.start();
        async.elapse(shortBreakDuration);
        async.flushMicrotasks();

        expect(audio.playCount, 0);
        expect(haptic.alarmCount, 0);
      });
    });

    test('초기화하면 울리던 알람이 멈춘다', () {
      fakeAsync((async) {
        final audio = FakeAudioService();
        final haptic = FakeHapticService();
        final container = buildContainer(audio: audio, haptic: haptic);
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.start();
        async.elapse(focusDuration);
        async.flushMicrotasks();

        final stopsBefore = audio.stopCount;
        viewModel.reset();
        async.flushMicrotasks();

        expect(audio.stopCount, greaterThan(stopsBefore));
        expect(haptic.cancelCount, greaterThan(0));
      });
    });
  });

  group('초기화', () {
    test('집중 모드로 되돌리되 누적 기록은 유지한다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.start();
        async.elapse(focusDuration);
        viewModel.reset();

        final state = container.read(timerViewModel);
        expect(state.mode, TimerMode.focus);
        expect(state.remaining, focusDuration);
        expect(state.cycleCount, 0);
        expect(state.completedFocusCount, 1, reason: '누적 세션은 지우지 않는다');
      });
    });

    test('초기화 후에는 타이머가 더 이상 진행되지 않는다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.start();
        async.elapse(const Duration(minutes: 5));
        viewModel.reset();
        async.elapse(const Duration(minutes: 10));

        expect(container.read(timerViewModel).remaining, focusDuration);
      });
    });
  });

  group('모드 선택', () {
    test('모드를 바꾸면 해당 시간으로 초기화되고 멈춘다', () {
      fakeAsync((async) {
        final container = buildContainer();
        addTearDown(container.dispose);
        final viewModel = container.read(timerViewModel.notifier);

        viewModel.start();
        async.elapse(const Duration(minutes: 5));
        viewModel.selectMode(TimerMode.longBreak);

        final state = container.read(timerViewModel);
        expect(state.mode, TimerMode.longBreak);
        expect(state.remaining, longBreakDuration);
        expect(state.isRunning, isFalse);
      });
    });
  });

  group('TimerState', () {
    test('세션이 없으면 집중 시간 합계는 0이다', () {
      final state = TimerState.initial(focusDuration);
      expect(state.totalFocusTime, Duration.zero);
      expect(state.completedFocusCount, 0);
    });
  });
}
