import 'package:flutter/material.dart';
import 'package:soonmodoro/features/timer/view/components/surface_card.dart';
import 'package:soonmodoro/shared/ui/app_colors.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      spacing: 10,
      children: [
        SurfaceCard(
          child: TextButton(
            onPressed: onReset,
            child: Text(
              '초기화',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: SurfaceCard(
            child: TextButton(
              onPressed: onToggle,
              child: Text(
                isRunning ? '중지' : '시작',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
