import 'package:soonmodoro/shared/lib/audio_service.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

/// 플랫폼 채널을 건드리지 않는 대역. 부모의 메서드가 호출되지 않으므로
/// `AudioPlayer`도 생성되지 않는다.
///
/// [ready]를 false로 주면 에셋 로드에 실패한 상황을 흉내낸다. 실제
/// [AudioService]와 마찬가지로 준비되지 않았으면 재생을 건너뛴다.
class FakeAudioService extends AudioService {
  FakeAudioService({this.ready = true, this.initDelay = Duration.zero});

  final bool ready;

  /// 에셋 로드에 걸리는 시간. 초기화가 끝나기 전 상태를 관찰할 때 쓴다.
  final Duration initDelay;

  int initCount = 0;
  int playCount = 0;
  int stopCount = 0;

  @override
  bool get isReady => ready;

  @override
  Future<void> init() async {
    initCount++;
    if (initDelay > Duration.zero) {
      await Future<void>.delayed(initDelay);
    }
  }

  @override
  Future<void> playFromStart() async {
    if (!ready) return;
    playCount++;
  }

  @override
  Future<void> stop() async {
    if (!ready) return;
    stopCount++;
  }

  @override
  void dispose() {}
}

class FakeHapticService extends HapticService {
  int alarmCount = 0;
  int cancelCount = 0;

  @override
  Future<void> tap() async {}

  @override
  Future<void> alarm({required Duration duration}) async => alarmCount++;

  @override
  Future<void> cancel() async => cancelCount++;
}
