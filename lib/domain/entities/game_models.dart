class PresidentInfo {
  const PresidentInfo({
    required this.id,
    required this.name,
    required this.nickname,
    required this.startYear,
    required this.endYear,
    required this.eraId,
    required this.tone,
  });

  final String id;
  final String name;
  final String nickname;
  final int startYear;
  final int endYear;
  final String eraId;
  final String tone;

  factory PresidentInfo.fromJson(Map<String, dynamic> json) => PresidentInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String,
        startYear: json['startYear'] as int,
        endYear: json['endYear'] as int,
        eraId: json['eraId'] as String,
        tone: json['tone'] as String,
      );
}

class EraInfo {
  const EraInfo({
    required this.id,
    required this.name,
    required this.generationLabel,
    required this.description,
    required this.startYear,
    required this.endYear,
  });

  final String id;
  final String name;
  final String generationLabel;
  final String description;
  final int startYear;
  final int endYear;

  factory EraInfo.fromJson(Map<String, dynamic> json) => EraInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        generationLabel: json['generationLabel'] as String,
        description: json['description'] as String,
        startYear: json['startYear'] as int,
        endYear: json['endYear'] as int,
      );
}

class NationalEventInfo {
  const NationalEventInfo({
    required this.id,
    required this.year,
    required this.title,
    required this.headline,
    required this.description,
    this.phaseForce,
    this.articleId,
    this.fallbackImage,
  });

  final String id;
  final int year;
  final String title;
  final String headline;
  final String description;
  final String? phaseForce;
  final String? articleId;
  final String? fallbackImage;

  String get effectiveArticleId => articleId ?? id;

  factory NationalEventInfo.fromJson(Map<String, dynamic> json) =>
      NationalEventInfo(
        id: json['id'] as String,
        year: json['year'] as int,
        title: json['title'] as String,
        headline: json['headline'] as String? ?? '',
        description: json['description'] as String,
        phaseForce: json['phaseForce'] as String?,
        articleId: json['articleId'] as String?,
        fallbackImage: json['fallbackImage'] as String?,
      );
}

class PhaseInfo {
  const PhaseInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.narrativeTone,
  });

  final String id;
  final String name;
  final String description;
  final String colorHex;
  final String narrativeTone;

  factory PhaseInfo.fromJson(Map<String, dynamic> json) => PhaseInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        colorHex: json['color'] as String,
        narrativeTone: json['narrativeTone'] as String,
      );
}

class GameEventChoice {
  const GameEventChoice({
    required this.text,
    required this.effects,
  });

  final String text;
  final Map<String, int> effects;
}

class GameEvent {
  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String description;
  final List<GameEventChoice> choices;
  final String? imageAsset;
}
