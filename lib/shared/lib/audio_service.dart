import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioPlayer? player;

  bool get isReady => player != null;

  Future<void> init() async {
    player = AudioPlayer();

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
    } catch (e) {
      log(e.toString());
      return;
    }

    try {
      await player?.setAsset('assets/audios/default.mp3');
    } catch (e) {
      log(e.toString());
      return;
    }

    await player?.setLoopMode(LoopMode.one);
  }

  /// 항상 처음부터 재생한다. [AudioPlayer.stop]은 재생 위치를 유지하므로
  /// seek 없이 play하면 두 번째 알람이 중간부터 나온다.
  Future<void> playFromStart() async {
    try {
      await player?.seek(Duration.zero);
      await player?.play();
    } catch (e) {
      log(e.toString());
      return;
    }
  }

  Future<void> stop() async {
    try {
      await player?.stop();
    } catch (e) {
      log(e.toString());
      return;
    }
  }

  void dispose() {
    player?.dispose();
  }
}
