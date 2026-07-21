/// 타이머 모드.
///
/// 지속 시간은 [TimerDurations]가 소유한다. 디버그 빌드에서 짧은 값을 쓰기
/// 위해서인데, 그 분기를 enum에 넣으면 테스트에서 실제 시간을 검증할 수 없다.
enum TimerMode {
  focus('집중'),
  shortBreak('짧은 휴식'),
  longBreak('긴 휴식');

  final String label;

  const TimerMode(this.label);
}
