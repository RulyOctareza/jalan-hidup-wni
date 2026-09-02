import 'dart:convert';

import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeLocalSource {
  LifeLocalSource(this._prefs);

  static const _saveKey = 'life_save_v1';
  final SharedPreferences _prefs;

  static SharedPreferences? _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static LifeLocalSource get instance {
    final prefs = _instance;
    if (prefs == null) {
      throw StateError('LifeLocalSource not initialized');
    }
    return LifeLocalSource(prefs);
  }

  Future<LifeSave?> loadSave() async {
    final raw = _prefs.getString(_saveKey);
    if (raw == null) return null;
    return LifeSave.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLife(LifeSave save) async {
    await _prefs.setString(_saveKey, jsonEncode(save.toJson()));
  }

  Future<void> clearSave() async {
    await _prefs.remove(_saveKey);
  }

  bool hasSave() => _prefs.containsKey(_saveKey);
}
