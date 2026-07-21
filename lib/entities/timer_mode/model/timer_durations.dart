import 'timer_mode.dart';

class TimerDurations {
  final Duration focus, shortBreak, longBreak;

  const TimerDurations({
    required this.focus,
    required this.shortBreak,
    required this.longBreak,
  });

  factory TimerDurations.real() {
    return TimerDurations(
      focus: Duration(seconds: 25 * 60),
      shortBreak: Duration(seconds: 5 * 60),
      longBreak: Duration(seconds: 15 * 60),
    );
  }
  factory TimerDurations.debug() {
    return TimerDurations(
      focus: Duration(seconds: 5),
      shortBreak: Duration(seconds: 3),
      longBreak: Duration(seconds: 5),
    );
  }

  Duration of(TimerMode mode) {
    return switch (mode) {
      TimerMode.focus => focus,
      TimerMode.shortBreak => shortBreak,
      TimerMode.longBreak => longBreak,
    };
  }
}
