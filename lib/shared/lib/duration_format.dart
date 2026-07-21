/// [duration]을 `mm:ss` 형태로 포맷한다. 음수는 `00:00`으로 취급한다.
String formatMmSs(Duration duration) {
  final total = duration.isNegative ? 0 : duration.inSeconds;
  final minutes = (total ~/ 60).toString().padLeft(2, '0');
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
