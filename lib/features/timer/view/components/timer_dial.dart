import 'dart:math';

import 'package:flutter/material.dart';
import 'package:soonmodoro/entities/timer_mode/model/timer_mode.dart';
import 'package:soonmodoro/features/timer/view/components/corner_border_painter.dart';
import 'package:soonmodoro/shared/lib/duration_format.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

/// 남은 시간을 원형 진행률과 숫자로 보여준다.
///
/// 크기를 인자로 받지 않고 부모가 준 공간에서 스스로 정한다. 가로모드처럼
/// 세로 공간이 줄어드는 상황에서도 호출부를 고칠 필요가 없다.
class TimerDial extends StatelessWidget {
  /// 기존 화면의 고정 크기. 아래 비율은 모두 이 값을 기준으로 계산된다.
  static const _preferredSize = 250.0;

  /// 상태가 갱신되는 주기. 링 애니메이션의 길이와 같아야 한다.
  static const _tick = Duration(seconds: 1);

  final TimerMode mode;
  final Duration remaining;
  final Duration total;
  final bool isRunning;

  const TimerDial({
    super.key,
    required this.mode,
    required this.remaining,
    required this.total,
    required this.isRunning,
  });

  /// 링이 향할 지점.
  ///
  /// 진행 중일 때는 **다음 틱의 남은 시간**을 목표로 잡는다. 현재 값을 목표로
  /// 두면 링이 거기 도달하는 순간 다음 갱신이 들어와, 링이 항상 숫자보다
  /// 1초 뒤처진 채로 따라간다.
  double get _targetFraction {
    if (total.inMilliseconds == 0) return 0;

    final target = isRunning ? remaining - _tick : remaining;
    return (target.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 공간이 넉넉하면 원래 크기(250)를 유지하고, 모자랄 때만 줄어든다.
        final size = min(
          min(constraints.maxWidth, constraints.maxHeight),
          _preferredSize,
        );
        final ringSize = size * 0.8;
        final fraction = _targetFraction;

        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: CornerBorderPainter(
                cornerLength: size * 0.08,
                strokeWidth: 3,
                color: trackColor,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: fraction, end: fraction),
              // 멈춰 있을 때는 즉시 반영한다. 완료·초기화·모드변경으로 남은
              // 시간이 되돌아갈 때 링이 역방향으로 한 바퀴 도는 것을 막는다.
              duration: isRunning ? _tick : Duration.zero,
              curve: Curves.linear,
              builder: (context, value, child) {
                return SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: value, // 시간이 갈수록 0으로 감소
                    strokeWidth: ringSize * 0.075,
                    strokeCap: StrokeCap.round,
                    color: primaryColor,
                    backgroundColor: trackColor,
                  ),
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mode.label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: size * 0.056,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatMmSs(remaining),
                  style: TextStyle(
                    fontSize: size * 0.216,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
