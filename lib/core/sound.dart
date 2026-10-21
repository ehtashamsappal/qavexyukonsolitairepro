import 'package:audioplayers/audioplayers.dart';

/// Simple sound effects + looping background music player.
/// All clips are local WAV assets generated for this game.
class SoundService {
  SoundService._();
  static final SoundService I = SoundService._();

  bool enabled = true;
  AudioPlayer? _bgm;

  Future<void> play(String name) async {
    if (!enabled) return;
    try {
      final p = AudioPlayer();
      p.onPlayerComplete.listen((_) {
        p.dispose();
      });
      await p.play(AssetSource('audio/$name.wav'));
    } catch (_) {
      // Audio is best-effort; never crash the game.
    }
  }

  Future<void> startBgm() async {
    if (!enabled || _bgm != null) return;
    try {
      final bgm = AudioPlayer();
      await bgm.setReleaseMode(ReleaseMode.loop);
      await bgm.play(AssetSource('audio/bgm.wav'));
      _bgm = bgm;
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try {
      await _bgm?.stop();
      await _bgm?.dispose();
    } catch (_) {}
    _bgm = null;
  }
}
