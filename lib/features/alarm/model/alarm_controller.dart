import 'package:soonmodoro/shared/lib/audio_service.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

/// 알람 소리와 진동을 한 쌍으로 묶는다.
///
/// 정지 경로를 [stop] 하나로 모으는 것이 이 클래스의 존재 이유다. 이전에는
/// 시작·초기화·모드변경 세 곳에 같은 정지 코드가 복붙돼 있었고, 그 탓에
/// dispose에서 진동 취소만 빠뜨리는 일이 생겼다.
class AlarmController {
  static const _vibrationDuration = Duration(seconds: 5);

  final AudioService _audio;
  final HapticService _haptic;

  AlarmController(this._audio, this._haptic);

  /// 알람을 울린다. 소리와 진동 중 하나가 실패해도 나머지는 진행한다.
  Future<void> ring() async {
    await Future.wait([
      _audio.playFromStart(),
      _haptic.alarm(duration: _vibrationDuration),
    ]);
  }

  /// 울리는 중인 소리와 진동을 모두 멈춘다. 울리지 않는 상태에서 호출해도 안전하다.
  Future<void> stop() async {
    await Future.wait([_audio.stop(), _haptic.cancel()]);
  }

  void dispose() {
    _haptic.cancel();
    _audio.dispose();
  }
}
