import 'package:flutter/material.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';

/// Picks scene background + era tint from province, age, job, health, year.
class SceneContext {
  const SceneContext({
    required this.backgroundAsset,
    required this.eraLabel,
    required this.overlayGradient,
    required this.sceneLabel,
  });

  final String backgroundAsset;
  final String eraLabel;
  final List<Color> overlayGradient;
  final String sceneLabel;
}

abstract final class SceneResolver {
  static const _urban = {
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Timur',
    'Bali',
    'Sumatera Utara',
  };

  static const _rural = {
    'Aceh',
    'Papua',
    'Kalimantan Timur',
    'Sulawesi Selatan',
    'Jawa Tengah',
  };

  static SceneContext resolve(LifeSave save) {
    final bg = _backgroundFor(save);
    final era = _eraFor(save.currentYear);
    return SceneContext(
      backgroundAsset: bg,
      eraLabel: era.label,
      overlayGradient: era.gradient,
      sceneLabel: _sceneLabel(save, bg),
    );
  }

  static String _backgroundFor(LifeSave save) {
    if (save.health < 28) return AssetPaths.background('hospital');
    if (save.age >= 6 && save.age <= 17) {
      return AssetPaths.background('school');
    }
    if (save.age >= 17 && save.jobTitle != null) {
      return AssetPaths.background('office');
    }
    if (_urban.contains(save.character.province)) {
      return AssetPaths.background('home_urban');
    }
    if (_rural.contains(save.character.province)) {
      return AssetPaths.background('home_rural');
    }
    return save.age < 18
        ? AssetPaths.background('home_rural')
        : AssetPaths.background('home_urban');
  }

  static String _sceneLabel(LifeSave save, String bg) {
    if (bg.contains('hospital')) return 'Rumah Sakit';
    if (bg.contains('school')) return 'Sekolah • ${save.character.province}';
    if (bg.contains('office')) return '${save.jobTitle} • ${save.character.province}';
    if (bg.contains('rural')) return 'Kampung • ${save.character.province}';
    return 'Kota • ${save.character.province}';
  }

  static _EraStyle _eraFor(int year) {
    if (year < 1967) {
      return _EraStyle('Orde Lama', [
        const Color(0xFF5D4037).withValues(alpha: 0.55),
        const Color(0xFF3E2723).withValues(alpha: 0.75),
      ]);
    }
    if (year < 1998) {
      return _EraStyle('Orde Baru', [
        const Color(0xFF33691E).withValues(alpha: 0.45),
        const Color(0xFF1B5E20).withValues(alpha: 0.72),
      ]);
    }
    if (year < 2004) {
      return _EraStyle('Reformasi', [
        const Color(0xFF37474F).withValues(alpha: 0.5),
        const Color(0xFF263238).withValues(alpha: 0.78),
      ]);
    }
    if (year < 2014) {
      return _EraStyle('Era SBY', [
        const Color(0xFF1565C0).withValues(alpha: 0.35),
        const Color(0xFF0D47A1).withValues(alpha: 0.65),
      ]);
    }
    if (year < 2024) {
      return _EraStyle('Era Jokowi', [
        const Color(0xFF2E7D32).withValues(alpha: 0.4),
        const Color(0xFF1B5E20).withValues(alpha: 0.68),
      ]);
    }
    return _EraStyle('Era Baru', [
      const Color(0xFF4527A0).withValues(alpha: 0.38),
      const Color(0xFF311B92).withValues(alpha: 0.7),
    ]);
  }
}

class _EraStyle {
  const _EraStyle(this.label, this.gradient);
  final String label;
  final List<Color> gradient;
}
