import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/shared/lib/duration_format.dart';

void main() {
  test('분과 초를 두 자리로 채운다', () {
    expect(formatMmSs(const Duration(minutes: 25)), '25:00');
    expect(formatMmSs(const Duration(minutes: 4, seconds: 5)), '04:05');
    expect(formatMmSs(Duration.zero), '00:00');
  });

  test('60분 이상은 분이 계속 늘어난다', () {
    expect(formatMmSs(const Duration(hours: 1, minutes: 5)), '65:00');
  });

  test('음수는 00:00으로 표시한다', () {
    expect(formatMmSs(const Duration(seconds: -3)), '00:00');
  });
}
