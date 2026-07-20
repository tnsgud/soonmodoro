import 'package:flutter/material.dart';
import 'package:soonmodoro/screens/home_screen.dart';
import 'package:soonmodoro/models/timer_mode.dart';

class SelectionButton extends StatelessWidget {
  final TimerMode timerMode;
  final String label;
  final void Function() onTap;

  const SelectionButton({
    super.key,
    required this.timerMode,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: timerMode == HomeScreen.timerMode
              ? Colors.deepPurple
              : Colors.white,
        ),
      ),
    );
  }
}
