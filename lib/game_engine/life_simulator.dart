import 'dart:math';

import 'package:jalan_hidup_wni/domain/entities/character.dart';
import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/game_engine/activity_engine.dart';
import 'package:jalan_hidup_wni/game_engine/event_pool.dart';
import 'package:jalan_hidup_wni/game_engine/history_context.dart';
import 'package:jalan_hidup_wni/game_engine/phase_resolver.dart';

class AgeUpResult {
  const AgeUpResult({
    required this.save,
    this.nationalEvent,
    this.randomEvent,
    this.newsHeadline,
    this.died = false,
  });

  final LifeSave save;
  final NationalEventInfo? nationalEvent;
  final GameEvent? randomEvent;
  final String? newsHeadline;
  final bool died;
}

class LifeSimulator {
  LifeSimulator({
    HistoryContext? history,
    PhaseResolver? phaseResolver,
    EventPool? eventPool,
    Random? random,
  })  : _history = history ?? HistoryContext(),
        _phaseResolver = phaseResolver ?? PhaseResolver(),
        _eventPool = eventPool ?? EventPool(random: random),
        _random = random ?? Random();

  final HistoryContext _history;
  final PhaseResolver _phaseResolver;
  final EventPool _eventPool;
  final Random _random;

  LifeSave createNewLife(Character character) {
    return LifeSave(
      character: character,
      age: 0,
      happiness: 70 + _random.nextInt(21),
      health: 80 + _random.nextInt(16),
      smarts: 40 + _random.nextInt(31),
      looks: 40 + _random.nextInt(31),
      wealth: _startingWealth(character.background),
      reputation: 50,
      phaseId: 'innocence',
      energy: ActivityEngine.defaultMaxEnergy,
      maxEnergy: ActivityEngine.defaultMaxEnergy,
      log: [
        LifeLogEntry(
          age: 0,
          message: '${character.name} dilahirkan di ${character.province}.',
        ),
      ],
      criticalFlags: [],
    );
  }

  int _startingWealth(String background) => switch (background) {
        'miskin' => 500_000,
        'kaya' => 50_000_000,
        'elite' => 200_000_000,
        _ => 5_000_000,
      };

  Future<AgeUpResult> ageUp({
    required LifeSave save,
    required List<PresidentInfo> presidents,
    required List<EraInfo> eras,
    required List<NationalEventInfo> nationalEvents,
  }) async {
    var next = save.copyWith(
      age: save.age + 1,
      energy: save.maxEnergy,
    );
    final year = next.currentYear;
    final president = _history.presidentAtYear(year, presidents);
    final national = _history.eventAtYear(year, nationalEvents);

    final logs = List<LifeLogEntry>.from(next.log);
    final headline = _history.buildNewsHeadline(
      year: year,
      age: next.age,
      president: president,
      nationalEvent: national,
    );
    logs.insert(
      0,
      LifeLogEntry(age: next.age, message: headline),
    );

    next = _applyYearlyDrift(next, national);

    if (national != null) {
      logs.insert(
        0,
        LifeLogEntry(
          age: next.age,
          message: '🔴 ${national.title}: ${national.description}',
        ),
      );
      if (national.phaseForce != null) {
        next = next.copyWith(phaseId: national.phaseForce!);
      }
    }

    final phaseId = _phaseResolver.resolve(next);
    next = next.copyWith(phaseId: phaseId, log: logs);

    GameEvent? randomEvent;
    randomEvent = await _eventPool.rollAgeUpEvent(next);

    var died = false;
    if (next.health <= 0 || next.age >= 95) {
      died = true;
      final legacy = _calcLegacy(next);
      next = next.copyWith(
        isAlive: false,
        health: 0,
        legacyScore: legacy,
        log: [
          LifeLogEntry(
            age: next.age,
            message: '${next.character.name} meninggal dunia usia '
                '${next.age} tahun. Legacy: $legacy',
          ),
          ...logs,
        ],
      );
    }

    return AgeUpResult(
      save: next,
      nationalEvent: national,
      randomEvent: randomEvent,
      newsHeadline: headline,
      died: died,
    );
  }

  LifeSave _applyYearlyDrift(LifeSave s, NationalEventInfo? national) {
    var h = s.happiness + _random.nextInt(11) - 5;
    var hp = s.health + _random.nextInt(7) - 3;
    var sm = s.smarts + (s.age >= 6 && s.age <= 22 ? 2 : 0);
    var w = s.wealth + _incomeForAge(s);

    if (national != null) {
      h -= 8;
      w -= 2_000_000;
    }

    return s.copyWith(
      happiness: h.clamp(0, 100),
      health: hp.clamp(0, 100),
      smarts: sm.clamp(0, 100),
      wealth: w.clamp(0, 999_999_999),
    );
  }

  int _incomeForAge(LifeSave s) {
    if (s.age < 17) return 0;
    if (s.jobTitle != null) {
      return 2_500_000 + s.smarts * 40_000;
    }
    if (s.age < 23) return 500_000;
    if (s.age < 40) return 1_500_000 + s.smarts * 30_000;
    return 1_000_000;
  }

  int _calcLegacy(LifeSave s) {
    return ((s.wealth ~/ 1_000_000) +
            s.happiness +
            s.reputation +
            s.smarts +
            (s.age * 2))
        .clamp(0, 1000);
  }

  LifeSave applyEventChoice(LifeSave save, GameEventChoice choice) {
    var h = save.happiness;
    var hp = save.health;
    var sm = save.smarts;
    var w = save.wealth;
    var r = save.reputation;

    choice.effects.forEach((key, value) {
      switch (key) {
        case 'happiness':
          h += value;
        case 'health':
          hp += value;
        case 'smarts':
          sm += value;
        case 'wealth':
          w += value;
        case 'reputation':
          r += value;
      }
    });

    final logs = List<LifeLogEntry>.from(save.log);
    logs.insert(
      0,
      LifeLogEntry(age: save.age, message: '✓ ${choice.text}'),
    );

    final updated = save.copyWith(
      happiness: h.clamp(0, 100),
      health: hp.clamp(0, 100),
      smarts: sm.clamp(0, 100),
      wealth: w.clamp(0, 999_999_999),
      reputation: r.clamp(0, 100),
      log: logs,
    );
    return updated.copyWith(phaseId: _phaseResolver.resolve(updated));
  }

  String avatarKeyFor(LifeSave save) {
    final g = save.character.gender == Gender.male ? 'male' : 'female';
    if (save.age <= 12) return 'child_$g';
    if (save.age <= 17) return 'teen_$g';
    if (save.age <= 60) return 'adult_$g';
    return 'elderly_$g';
  }
}
