import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:jalan_hidup_wni/core/constants/audio_paths.dart';

/// Manages looping BGM + one-shot SFX with crossfade between tracks.
class AudioService {
  AudioService() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setVolume(_bgmVolume);
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  static const double _bgmVolume = 0.45;
  static const double _sfxVolume = 0.7;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _currentBgm;
  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      _bgmPlayer.stop();
    }
  }

  Future<void> playBgm(String assetPath) async {
    if (!_enabled) return;
    if (_currentBgm == assetPath) return;

    _currentBgm = assetPath;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('BGM play error: $e');
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
