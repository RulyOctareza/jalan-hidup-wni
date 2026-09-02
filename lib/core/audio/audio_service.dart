import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:jalan_hidup_wni/core/constants/audio_paths.dart';

/// Manages looping BGM + one-shot SFX with crossfade between tracks.
class AudioService {
  AudioService() {
    _init();
  }

  static const double _bgmVolume = 0.55;
  static const double _sfxVolume = 0.75;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentBgm;
  bool _enabled = true;
  bool _initialized = false;

  bool get enabled => _enabled;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;

    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      _bgmPlayer.stop();
    } else if (_currentBgm != null) {
      playBgm(_currentBgm!, force: true);
    }
  }

  Future<void> playBgm(String assetPath, {bool force = false}) async {
    await _init();
    if (!_enabled) return;
    if (!force && _currentBgm == assetPath) return;

    _currentBgm = assetPath;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(assetPath));
      debugPrint('BGM playing: $assetPath');
    } catch (e, st) {
      debugPrint('BGM play error ($assetPath): $e\n$st');
    }
  }

  Future<void> playBgmForPhase(String phaseId) async {
    await playBgm(AudioPaths.bgmForPhase(phaseId));
  }

  Future<void> playMenuBgm() => playBgm(AudioPaths.bgmMenu);

  Future<void> playLegacyBgm() => playBgm(AudioPaths.bgmLifeLegacy);

  Future<void> stopBgm() async {
    _currentBgm = null;
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    await _init();
    if (!_enabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('SFX play error: $e');
    }
  }

  Future<void> tap() => playSfx(AudioPaths.sfxTap);
  Future<void> ageUp() => playSfx(AudioPaths.sfxAgeUp);
  Future<void> positive() => playSfx(AudioPaths.sfxPositive);
  Future<void> negative() => playSfx(AudioPaths.sfxNegative);
  Future<void> event() => playSfx(AudioPaths.sfxEvent);

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
