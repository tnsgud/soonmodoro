import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soonmodoro/features/alarm/model/alarm_controller.dart';
import 'package:soonmodoro/shared/lib/audio_service.dart';
import 'package:soonmodoro/shared/lib/haptic_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  // 에셋 로드는 오래 걸릴 수 있으므로 기다리지 않는다. 실패해도 isReady가
  // false로 남을 뿐 타이머 동작에는 영향이 없다.
  service.init();
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());

final alarmControllerProvider = Provider<AlarmController>((ref) {
  final controller = AlarmController(
    ref.watch(audioServiceProvider),
    ref.watch(hapticServiceProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
