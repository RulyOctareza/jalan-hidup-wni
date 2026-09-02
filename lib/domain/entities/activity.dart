import 'package:jalan_hidup_wni/domain/entities/game_models.dart';
import 'package:jalan_hidup_wni/domain/entities/life_save.dart';

class ActivityDefinition {
  const ActivityDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.energyCost,
    required this.minAge,
    this.maxAge,
    required this.effects,
    required this.logMessage,
    this.setsJob,
    this.recoverEnergy = 0,
  });

  final String id;
  final String name;
  final String icon;
  final int energyCost;
  final int minAge;
  final int? maxAge;
  final Map<String, int> effects;
  final String logMessage;
  final String? setsJob;
  final int recoverEnergy;

  bool isAvailableFor(int age) {
    if (age < minAge) return false;
    if (maxAge != null && age > maxAge!) return false;
    return true;
  }

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    return ActivityDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      energyCost: json['energyCost'] as int,
      minAge: json['minAge'] as int,
      maxAge: json['maxAge'] as int?,
      effects: (json['effects'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      logMessage: json['logMessage'] as String,
      setsJob: json['setsJob'] as String?,
      recoverEnergy: json['recoverEnergy'] as int? ?? 0,
    );
  }
}

class ActivityResult {
  const ActivityResult({
    required this.save,
    this.surpriseEvent,
    this.message,
  });

  final LifeSave save;
  final GameEvent? surpriseEvent;
  final String? message;
}
