import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';
import 'package:soonmodoro/features/timer/view/components/alarm_notice.dart';
import 'package:soonmodoro/features/timer/view/components/cycle_progress.dart';
import 'package:soonmodoro/features/timer/view/components/mode_selector.dart';
import 'package:soonmodoro/features/timer/view/components/state_row.dart';
import 'package:soonmodoro/features/timer/view/components/timer_controls.dart';
import 'package:soonmodoro/features/timer/view/components/timer_dial.dart';
import 'package:soonmodoro/features/timer/view/components/timer_header.dart';
import 'package:soonmodoro/features/timer/view_model/timer_view_model.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

/// [WidgetRef]를 아는 유일한 위젯.
///
/// 하위 컴포넌트는 전부 props와 콜백만 받는다. Riverpod 컨테이너 없이도
/// 렌더링되므로 위젯 테스트가 가볍다.
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerViewModel);
    final viewModel = ref.read(timerViewModel.notifier);
    final durations = ref.watch(timerDurationsProvider);
    // 초기화 중이거나 성공했으면 안내를 띄우지 않는다.
    final alarmFailed = ref.watch(alarmReadyProvider).value == false;

    return Scaffold(
      backgroundColor: bgColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                child: Row(
                  children: [
                    if (alarmFailed) AlarmNotice(),
                    TimerDial(
                      mode: state.mode,
                      remaining: state.remaining,
                      total: durations.of(state.mode),
                      isRunning: state.isRunning,
                    ),
                    SizedBox(width: 30),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TimerHeader(),
                          CycleProgress(cycleCount: state.cycleCount),
                          SizedBox(height: 20),
                          ModeSelector(
                            selected: state.mode,
                            onSelect: viewModel.selectMode,
                          ),
                          const SizedBox(height: 10),
                          TimerControls(
                            isRunning: state.isRunning,
                            onToggle: viewModel.toggle,
                            onReset: viewModel.reset,
                          ),
                          const SizedBox(height: 10),
                          StateRow(
                            sessionCount: state.completedFocusCount,
                            focusTime: state.totalFocusTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const TimerHeader(),
                  CycleProgress(cycleCount: state.cycleCount),
                  if (alarmFailed) const AlarmNotice(),
                  Expanded(
                    child: TimerDial(
                      mode: state.mode,
                      remaining: state.remaining,
                      total: durations.of(state.mode),
                      isRunning: state.isRunning,
                    ),
                  ),
                  ModeSelector(
                    selected: state.mode,
                    onSelect: viewModel.selectMode,
                  ),
                  const SizedBox(height: 10),
                  TimerControls(
                    isRunning: state.isRunning,
                    onToggle: viewModel.toggle,
                    onReset: viewModel.reset,
                  ),
                  const SizedBox(height: 10),
                  StateRow(
                    sessionCount: state.completedFocusCount,
                    focusTime: state.totalFocusTime,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
