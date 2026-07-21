import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// 알람 소리 재생. `just_audio`와 `audio_session`을 아는 유일한 곳이다.
class AudioService {
  AudioPlayer? _player;
  Future<void>? _initFuture;
  bool _isReady = false;

  /// 에셋 로드까지 성공해 실제로 소리를 낼 수 있는 상태인지.
  ///
  /// 오디오 세션 설정이나 에셋 로드가 실패하면 false로 남는다. `_player`가
  /// null인지로 판단하면, 플레이어 객체는 만들어졌지만 에셋이 없는 상태를
  /// 준비 완료로 잘못 보고하게 된다.
  bool get isReady => _isReady;

  /// 여러 번 호출해도 초기화는 한 번만 수행하고, 이후에는 같은 Future를 돌려준다.
  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    final player = _player ??= AudioPlayer();

    try {
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.alarm,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false,
        ),
      );
      await player.setAsset('assets/audios/default.mp3');
      await player.setLoopMode(LoopMode.one);
    } catch (e) {
      log('알람 오디오 초기화 실패: $e');
      return;
    }

    _isReady = true;
  }

  /// 항상 처음부터 재생한다. [AudioPlayer.stop]은 재생 위치를 유지하므로
  /// seek 없이 play하면 두 번째 알람이 중간부터 나온다.
  ///
  /// 초기화가 아직 끝나지 않았으면 기다린다. 첫 세션이 에셋 로드보다 먼저
  /// 끝나는 경우 소리가 조용히 누락되는 것을 막는다.
  Future<void> playFromStart() async {
    await init();
    if (!_isReady) return;

    try {
      await _player?.seek(Duration.zero);
      await _player?.play();
    } catch (e) {
      log('알람 재생 실패: $e');
    }
  }

  Future<void> stop() async {
    if (!_isReady) return;

    try {
      await _player?.stop();
    } catch (e) {
      log('알람 정지 실패: $e');
    }
  }

  void dispose() {
    _player?.dispose();
  }
}
