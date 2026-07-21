/// 남은 시간을 `mm:ss` 형태로 포맷한다. 음수는 `00:00`으로 취급한다.
///
/// 초를 **올림**하는 것이 핵심이다. 타이머 틱은 정확히 1.000초에 오지 않고
/// 몇 밀리초씩 늦게 발화하므로 남은 시간이 3.998초 같은 값이 된다. 이를
/// 버리면 4가 통째로 사라져 5에서 3으로 건너뛴 것처럼 보인다.
///
/// 올림하면 (3, 4] 구간이 모두 `00:04`로 표시되어, 카운트다운이 매 초 하나씩
/// 줄어드는 것으로 보인다.
String formatMmSs(Duration duration) {
  if (duration.isNegative) return '00:00';

  final total = (duration.inMicroseconds / Duration.microsecondsPerSecond)
      .ceil();
  final minutes = (total ~/ 60).toString().padLeft(2, '0');
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
