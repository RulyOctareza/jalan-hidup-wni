import 'package:jalan_hidup_wni/domain/entities/activity.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';
import 'package:jalan_hidup_wni/game_engine/event_pool.dart';
import 'package:jalan_hidup_wni/game_engine/phase_resolver.dart';

/// Performs player-chosen activities; spends energy; may trigger surprises.
class ActivityEngine {
  ActivityEngine({
    EventPool? eventPool,
    PhaseResolver? phaseResolver,
  })  : _eventPool = eventPool ?? EventPool(),
        _phaseResolver = phaseResolver ?? PhaseResolver();

  final EventPool _eventPool;
  final PhaseResolver _phaseResolver;

  static const int defaultMaxEnergy = 3;

  Future<ActivityResult> perform({
    required LifeSave save,
    required ActivityDefinition activity,
  }) async {
    if (activity.energyCost > 0 && save.energy < activity.energyCost) {
      return ActivityResult(
        save: save,
        message: 'Energi tidak cukup!',
      );
    }

    var h = save.happiness;
    var hp = save.health;
    var sm = save.smarts;
    var lk = save.looks;
    var w = save.wealth;
    var r = save.reputation;
    var energy = save.energy;
    var job = save.jobTitle;

    activity.effects.forEach((key, value) {
      switch (key) {
        case 'happiness':
          h += value;
        case 'health':
          hp += value;
        case 'smarts':
          sm += value;
        case 'looks':
          lk += value;
        case 'wealth':
          w += value;
        case 'reputation':
          r += value;
      }
    });

    if (activity.energyCost > 0) {
      energy -= activity.energyCost;
    }
    if (activity.recoverEnergy > 0) {
      energy = (energy + activity.recoverEnergy).clamp(0, save.maxEnergy);
    }
    if (activity.setsJob != null && (job == null || job.isEmpty)) {
      job = activity.setsJob;
    }

    final logs = List<LifeLogEntry>.from(save.log);
    logs.insert(
      0,
      LifeLogEntry(
        age: save.age,
        message: '⚡ ${activity.logMessage}',
      ),
    );

    var updated = save.copyWith(
      happiness: h.clamp(0, 100),
      health: hp.clamp(0, 100),
      smarts: sm.clamp(0, 100),
      looks: lk.clamp(0, 100),
      wealth: w.clamp(0, 999_999_999),
      reputation: r.clamp(0, 100),
      energy: energy,
      jobTitle: job,
      log: logs,
    );
    updated = updated.copyWith(phaseId: _phaseResolver.resolve(updated));

    final surprise = await _eventPool.rollSurpriseAfterActivity(updated);

    return ActivityResult(
      save: updated,
      surpriseEvent: surprise,
    );
  }
}
