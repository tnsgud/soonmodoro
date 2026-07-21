import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soonmodoro/features/alarm/model/alarm_provider.dart';

import '../../support/fake_services.dart';

/// 값이 아니라 팩토리를 대체한다. `audioServiceProvider`를 통째로 갈아끼우면
/// 본문의 초기화 호출과 `ref.onDispose` 등록이 실행되지 않아, 정작 검증하려는
/// 배선이 테스트에서 사라진다.
ProviderContainer buildContainer(FakeAudioService audio) {
  final haptic = FakeHapticService();
  return ProviderContainer(
    overrides: [
      audioServiceFactoryProvider.overrideWithValue(() => audio),
      hapticServiceFactoryProvider.overrideWithValue(() => haptic),
    ],
  );
}

void main() {
  group('AudioService 수명', () {
    test('타이머를 한 번도 조작하지 않아도 해제된다', () async {
      final audio = FakeAudioService();
      final container = buildContainer(audio);

      // 화면이 알람 상태만 관찰하고 AlarmController는 만들어지지 않은 상황.
      await container.read(alarmReadyProvider.future);
      container.dispose();

      expect(audio.disposeCount, 1);
    });

    test('AlarmController를 거쳐도 이중 해제되지 않는다', () {
      final audio = FakeAudioService();
      final container = buildContainer(audio);

      container.read(alarmControllerProvider);
      container.dispose();

      expect(audio.disposeCount, 1);
    });

    test('생성과 함께 초기화가 시작된다', () {
      final audio = FakeAudioService();
      final container = buildContainer(audio);
      addTearDown(container.dispose);

      container.read(audioServiceProvider);

      expect(audio.initCount, greaterThan(0));
    });
  });

  group('alarmReadyProvider', () {
    test('에셋 로드에 성공하면 true', () async {
      final container = buildContainer(FakeAudioService());
      addTearDown(container.dispose);

      expect(await container.read(alarmReadyProvider.future), isTrue);
    });

    test('실패하면 false', () async {
      final container = buildContainer(FakeAudioService(ready: false));
      addTearDown(container.dispose);

      expect(await container.read(alarmReadyProvider.future), isFalse);
    });
  });
}
