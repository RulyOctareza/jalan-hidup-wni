import 'package:jalan_hidup_wni/domain/entities/life_save.dart';

class PhaseResolver {
  String resolve(LifeSave save) {
    if (!save.isAlive || save.health <= 10) return 'near_death';
    if (save.age <= 7) return 'innocence';
    if (save.happiness <= 25 || save.health <= 20) return 'suffering';
    if (save.happiness <= 45 && save.wealth < 5_000_000) return 'struggling';
    if (save.happiness >= 70 && save.wealth >= 50_000_000) return 'success';
    if (save.happiness >= 55 && save.wealth >= 10_000_000) return 'rising';
    if (save.happiness <= 35) return 'decline';
    return 'surviving';
  }
}
