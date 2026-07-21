import 'package:flutter/material.dart';
import 'package:soonmodoro/app/theme/app_theme.dart';
import 'package:soonmodoro/features/timer/view/timer_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soonmodoro',
      theme: appTheme,
      home: const TimerScreen(),
    );
  }
}
