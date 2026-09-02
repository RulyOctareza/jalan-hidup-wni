import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jalan_hidup_wni/core/constants/asset_paths.dart';
import 'package:jalan_hidup_wni/domain/entities/activity.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';

/// Loads activities & surprise events; rolls unpredictable pop-ups.
class EventPool {
  EventPool({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<ActivityDefinition>? _activities;
  List<_EventTemplate>? _events;

  static const surpriseChanceAfterActivity = 0.22;
  static const surpriseChanceOnAgeUp = 0.38;

  Future<List<ActivityDefinition>> getActivities() async {
    if (_activities != null) return _activities!;
    final raw =
        await rootBundle.loadString('assets/content/game/activities.json');
    _activities = (jsonDecode(raw) as List<dynamic>)
        .map((e) => ActivityDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
    return _activities!;
  }

  Future<void> _loadEvents() async {
    if (_events != null) return;
    final raw = await rootBundle
        .loadString('assets/content/events/surprise_events.json');
    _events = (jsonDecode(raw) as List<dynamic>)
        .map((e) => _EventTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<ActivityDefinition> availableActivities(LifeSave save) {
    final acts = _activities ?? [];
    return acts.where((a) => a.isAvailableFor(save.age)).toList();
  }

  /// Random surprise after an activity — feels unpredictable.
  Future<GameEvent?> rollSurpriseAfterActivity(LifeSave save) async {
    await _loadEvents();
    if (_random.nextDouble() > surpriseChanceAfterActivity) return null;
    return _pickEvent(save, trigger: 'surprise');
  }

  Future<GameEvent?> rollAgeUpEvent(LifeSave save) async {
    await _loadEvents();
    if (_random.nextDouble() > surpriseChanceOnAgeUp) return null;
    return _pickEvent(save, trigger: 'age_up') ??
        _pickEvent(save, trigger: 'surprise');
  }

  GameEvent? _pickEvent(LifeSave save, {required String trigger}) {
    final pool = _events!
        .where((e) => e.matches(save, trigger: trigger))
        .toList();
    if (pool.isEmpty) return null;

    final totalWeight = pool.fold<int>(0, (s, e) => s + e.weight);
    var roll = _random.nextInt(totalWeight);
    for (final template in pool) {
      roll -= template.weight;
      if (roll < 0) return template.toGameEvent();
    }
    return pool.last.toGameEvent();
  }
}

class _EventTemplate {
  _EventTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.minAge,
    this.maxAge,
    this.requiresJob = false,
    required this.weight,
    required this.trigger,
    required this.choices,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String description;
  final int minAge;
  final int? maxAge;
  final bool requiresJob;
  final int weight;
  final String trigger;
  final List<GameEventChoice> choices;
  final String? imageAsset;

  bool matches(LifeSave save, {required String trigger}) {
    if (this.trigger != trigger) return false;
    if (save.age < minAge) return false;
    if (maxAge != null && save.age > maxAge!) return false;
    if (requiresJob && (save.jobTitle == null || save.jobTitle!.isEmpty)) {
      return false;
    }
    return true;
  }

  GameEvent toGameEvent() => GameEvent(
        id: id,
        title: title,
        description: description,
        choices: choices,
        imageAsset: imageAsset != null
            ? AssetPaths.event(imageAsset!)
            : null,
      );

  factory _EventTemplate.fromJson(Map<String, dynamic> json) {
    return _EventTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      minAge: json['minAge'] as int,
      maxAge: json['maxAge'] as int?,
      requiresJob: json['requiresJob'] as bool? ?? false,
      weight: json['weight'] as int,
      trigger: json['trigger'] as String,
      imageAsset: json['imageAsset'] as String?,
      choices: (json['choices'] as List<dynamic>)
          .map(
            (c) => GameEventChoice(
              text: c['text'] as String,
              effects: (c['effects'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, (v as num).toInt()),
              ),
            ),
          )
          .toList(),
    );
  }
}
