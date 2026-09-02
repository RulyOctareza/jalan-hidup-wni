import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';

class ContentSource {
  List<PresidentInfo>? _presidents;
  List<EraInfo>? _eras;
  List<NationalEventInfo>? _nationalEvents;
  List<PhaseInfo>? _phases;

  Future<List<PresidentInfo>> getPresidents() async {
    if (_presidents != null) return _presidents!;
    final raw = await rootBundle
        .loadString('assets/content/history/presidents.json');
    _presidents = (jsonDecode(raw) as List<dynamic>)
        .map((e) => PresidentInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return _presidents!;
  }

  Future<List<EraInfo>> getEras() async {
    if (_eras != null) return _eras!;
    final raw =
        await rootBundle.loadString('assets/content/history/eras.json');
    _eras = (jsonDecode(raw) as List<dynamic>)
        .map((e) => EraInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return _eras!;
  }

  Future<List<NationalEventInfo>> getNationalEvents() async {
    if (_nationalEvents != null) return _nationalEvents!;
    final raw = await rootBundle
        .loadString('assets/content/history/national_events.json');
    _nationalEvents = (jsonDecode(raw) as List<dynamic>)
        .map((e) => NationalEventInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return _nationalEvents!;
  }

  Future<List<PhaseInfo>> getPhases() async {
    if (_phases != null) return _phases!;
    final raw =
        await rootBundle.loadString('assets/content/game/life_phases.json');
    _phases = (jsonDecode(raw) as List<dynamic>)
        .map((e) => PhaseInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    return _phases!;
  }
}
