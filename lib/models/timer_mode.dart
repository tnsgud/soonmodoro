// const int twentyFiveMinutes = 25 * 60;
// const int fiveMinutes = 5 * 60;
// const int fifteen = 15 * 60;

import 'package:flutter/foundation.dart';

const int twentyFiveMinutes = kDebugMode ? 10 : 25 * 60;
const int fiveMinutes = kDebugMode ? 3 : 5 * 60;
const int fifteen = kDebugMode ? 5 : 15 * 60;

enum TimerMode {
  focus('집중', twentyFiveMinutes),
  shortBreak('짧은 휴식', fiveMinutes),
  longBreak('긴 휴식', fifteen);

  final String label;
  final int time;
  const TimerMode(this.label, this.time);
}
