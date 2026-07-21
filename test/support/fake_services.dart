import 'package:soonmodoro/shared/lib/audio_service.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

/// 플랫폼 채널을 건드리지 않는 대역. 부모의 메서드가 호출되지 않으므로
/// `AudioPlayer`도 생성되지 않는다.
class FakeAudioService extends AudioService {
  int playCount = 0;
  int stopCount = 0;

  @override
  bool get isReady => true;

  @override
  Future<void> init() async {}

  @override
  Future<void> playFromStart() async => playCount++;

  @override
  Future<void> stop() async => stopCount++;

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
