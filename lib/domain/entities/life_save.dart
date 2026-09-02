import 'package:jalan_hidup_wni/domain/entities/character.dart';

class LifeLogEntry {
  const LifeLogEntry({required this.age, required this.message});

  final int age;
  final String message;

  Map<String, dynamic> toJson() => {'age': age, 'message': message};

  factory LifeLogEntry.fromJson(Map<String, dynamic> json) => LifeLogEntry(
        age: json['age'] as int,
        message: json['message'] as String,
      );
}

class LifeSave {
  const LifeSave({
    required this.character,
    required this.age,
    required this.happiness,
    required this.health,
    required this.smarts,
    required this.looks,
    required this.wealth,
    required this.reputation,
    required this.phaseId,
    required this.log,
    required this.criticalFlags,
    this.energy = 3,
    this.maxEnergy = 3,
    this.jobTitle,
    this.isAlive = true,
    this.legacyScore = 0,
  });

  final Character character;
  final int age;
  final int happiness;
  final int health;
  final int smarts;
  final int looks;
  final int wealth;
  final int reputation;
  final String phaseId;
  final List<LifeLogEntry> log;
  final List<String> criticalFlags;
  final int energy;
  final int maxEnergy;
  final String? jobTitle;
  final bool isAlive;
  final int legacyScore;

  bool get hasEnergyLeft => energy > 0;

  int get currentYear => character.birthYear + age;

  LifeSave copyWith({
    int? age,
    int? happiness,
    int? health,
    int? smarts,
    int? looks,
    int? wealth,
    int? reputation,
    String? phaseId,
    List<LifeLogEntry>? log,
    List<String>? criticalFlags,
    int? energy,
    int? maxEnergy,
    String? jobTitle,
    bool? isAlive,
    int? legacyScore,
    bool clearJob = false,
  }) =>
      LifeSave(
        character: character,
        age: age ?? this.age,
        happiness: happiness ?? this.happiness,
        health: health ?? this.health,
        smarts: smarts ?? this.smarts,
        looks: looks ?? this.looks,
        wealth: wealth ?? this.wealth,
        reputation: reputation ?? this.reputation,
        phaseId: phaseId ?? this.phaseId,
        log: log ?? this.log,
        criticalFlags: criticalFlags ?? this.criticalFlags,
        energy: energy ?? this.energy,
        maxEnergy: maxEnergy ?? this.maxEnergy,
        jobTitle: clearJob ? null : (jobTitle ?? this.jobTitle),
        isAlive: isAlive ?? this.isAlive,
        legacyScore: legacyScore ?? this.legacyScore,
      );

  Map<String, dynamic> toJson() => {
        'character': character.toJson(),
        'age': age,
        'happiness': happiness,
        'health': health,
        'smarts': smarts,
        'looks': looks,
        'wealth': wealth,
        'reputation': reputation,
        'phaseId': phaseId,
        'log': log.map((e) => e.toJson()).toList(),
        'criticalFlags': criticalFlags,
        'energy': energy,
        'maxEnergy': maxEnergy,
        'jobTitle': jobTitle,
        'isAlive': isAlive,
        'legacyScore': legacyScore,
      };

  factory LifeSave.fromJson(Map<String, dynamic> json) => LifeSave(
        character:
            Character.fromJson(json['character'] as Map<String, dynamic>),
        age: json['age'] as int,
        happiness: json['happiness'] as int,
        health: json['health'] as int,
        smarts: json['smarts'] as int,
        looks: json['looks'] as int,
        wealth: json['wealth'] as int,
        reputation: json['reputation'] as int,
        phaseId: json['phaseId'] as String,
        log: (json['log'] as List<dynamic>)
            .map((e) => LifeLogEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        criticalFlags: (json['criticalFlags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        energy: json['energy'] as int? ?? 3,
        maxEnergy: json['maxEnergy'] as int? ?? 3,
        jobTitle: json['jobTitle'] as String?,
        isAlive: json['isAlive'] as bool? ?? true,
        legacyScore: json['legacyScore'] as int? ?? 0,
      );
}
