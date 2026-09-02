abstract final class AudioPaths {
  // BGM
  static const String bgmMenu = 'audio/bgm/bgm_menu.mp3';
  static const String bgmLifeWarm = 'audio/bgm/bgm_life_warm.mp3';
  static const String bgmLifeStruggle = 'audio/bgm/bgm_life_struggle.mp3';
  static const String bgmLifeSorrow = 'audio/bgm/bgm_life_sorrow.mp3';
  static const String bgmLifeHope = 'audio/bgm/bgm_life_hope.mp3';
  static const String bgmLifeLegacy = 'audio/bgm/bgm_life_legacy.mp3';

  // SFX
  static const String sfxTap = 'audio/sfx/sfx_tap.mp3';
  static const String sfxAgeUp = 'audio/sfx/sfx_age_up.mp3';
  static const String sfxPositive = 'audio/sfx/sfx_positive.mp3';
  static const String sfxNegative = 'audio/sfx/sfx_negative.mp3';
  static const String sfxEvent = 'audio/sfx/sfx_event.mp3';

  /// Map life phase → BGM track.
  static String bgmForPhase(String phaseId) => switch (phaseId) {
        'innocence' || 'surviving' => bgmLifeWarm,
        'struggling' || 'critical' => bgmLifeStruggle,
        'suffering' || 'decline' => bgmLifeSorrow,
        'rising' || 'recovery' || 'success' => bgmLifeHope,
        'near_death' => bgmLifeLegacy,
        _ => bgmLifeWarm,
      };
}
