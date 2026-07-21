import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// 햅틱·진동 플랫폼 래퍼.
///
/// [Vibration.hasVibrator]는 플랫폼 채널을 왕복하므로 최초 1회만 조회해 캐시한다.
class HapticService {
  bool? _hasVibrator;

  Future<bool> _supportsVibration() async {
    return _hasVibrator ??= await Vibration.hasVibrator();
  }

  /// 버튼 탭 피드백.
  Future<void> tap() async {
    await HapticFeedback.heavyImpact();
  }

  /// 알람 진동. 진동자가 없는 기기에서는 아무것도 하지 않는다.
  Future<void> alarm({required Duration duration}) async {
    if (await _supportsVibration()) {
      await Vibration.vibrate(duration: duration.inMilliseconds);
    }
  }

  /// 진행 중인 진동을 취소한다. 진동자 지원 여부와 무관하게 호출해도 안전하다.
  Future<void> cancel() async {
    await Vibration.cancel();
  }
}
