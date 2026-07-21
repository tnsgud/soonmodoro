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
  final TimerMode mode;
  final Duration remaining;
  final Duration total;

  const TimerDial({
    super.key,
    required this.mode,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final ringSize = size * 0.8;
        final fraction = total.inMilliseconds == 0
            ? 0.0
            : (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

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
              duration: const Duration(seconds: 1),
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
