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

  group('카운트다운에서 숫자를 건너뛰지 않는다', () {
    // 타이머 틱은 정확히 1.000초에 오지 않는다. 몇 밀리초 늦게 발화하므로
    // 남은 시간이 3.998초 같은 값이 된다. 버림으로 처리하면 4가 통째로
    // 사라져 5에서 3으로 건너뛴 것처럼 보인다.
    test('1초에 못 미치게 모자란 값은 올려서 표시한다', () {
      expect(formatMmSs(const Duration(milliseconds: 3998)), '00:04');
      expect(formatMmSs(const Duration(milliseconds: 4999)), '00:05');
      expect(formatMmSs(const Duration(milliseconds: 1)), '00:01');
    });

    test('딱 떨어지는 값은 그대로 표시한다', () {
      expect(formatMmSs(const Duration(seconds: 4)), '00:04');
      expect(formatMmSs(Duration.zero), '00:00');
    });

    test('분 경계에서도 올림이 적용된다', () {
      expect(formatMmSs(const Duration(milliseconds: 59999)), '01:00');
    });
  });
}
