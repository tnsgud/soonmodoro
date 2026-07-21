import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

/// 긴 휴식까지의 집중 사이클 진행도.
class CycleProgress extends StatelessWidget {
  static const _limit = 4;

  /// 0~4.
  final int cycleCount;

  const CycleProgress({super.key, required this.cycleCount});

  @override
  Widget build(BuildContext context) {
    final filled = cycleCount.clamp(0, _limit);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '집중 사이클 $filled/$_limit',
              style: TextStyle(
                fontSize: 10,
                color: mutedColor,
                letterSpacing: 2,
              ),
            ),
            Row(
              children: List.generate(_limit, (index) {
                return Container(
                  margin: EdgeInsets.only(left: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index < filled ? primaryColor : trackColor,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
        SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: filled / _limit),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: trackColor,
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            );
          },
        ),
      ],
    );
  }
}
