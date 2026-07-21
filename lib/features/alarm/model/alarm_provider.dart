import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/features/alarm/model/alarm_controller.dart';
import 'package:soonmodoro/shared/lib/audio_service.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  // 앱 시작과 함께 초기화를 걸어두되 기다리지는 않는다. 아직 끝나지 않은 채로
  // 알람 시점이 오면 playFromStart가 내부에서 기다린다.
  service.init();
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());

/// 알람 소리를 낼 수 있는 상태인지.
///
/// 초기화가 끝날 때까지 loading, 끝나면 성공 여부를 담는다. 실패했다면 화면이
/// 이를 알려야 한다. 로그만 남기면 사용자는 알람이 왜 안 울리는지 알 수 없다.
final alarmReadyProvider = FutureProvider<bool>((ref) async {
  final audio = ref.watch(audioServiceProvider);
  await audio.init();
  return audio.isReady;
});

final alarmControllerProvider = Provider<AlarmController>((ref) {
  final controller = AlarmController(
    ref.watch(audioServiceProvider),
    ref.watch(hapticServiceProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
