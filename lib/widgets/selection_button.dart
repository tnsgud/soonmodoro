import 'package:flutter/material.dart';
import 'package:soonmodoro/screens/home_screen.dart';
import 'package:soonmodoro/models/timer_mode.dart';

class SelectionButton extends StatelessWidget {
  final TimerMode timerMode;
  final String label;

  const SelectionButton({
    super.key,
    required this.timerMode,
    required this.label,
  });

  void _onTap(TimerMode mode) {}

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _onTap(timerMode),
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
