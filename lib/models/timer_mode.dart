const int twentyFiveMinutes = 5;
const int fiveMinutes = 1;
const int fifteen = 2;

enum TimerMode {
  focus('집중시간', twentyFiveMinutes),
  shortBreak('짧은 휴식', fiveMinutes),
  longBreak('긴 휴식', fifteen);

  final String label;
  final int time;
  const TimerMode(this.label, this.time);
}
