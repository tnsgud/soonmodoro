import 'package:flutter/material.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POMODORO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: mutedStrongColor,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '집중 타이머',
              style: TextStyle(
                color: primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
