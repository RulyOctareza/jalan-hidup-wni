enum Gender { male, female }

class Character {
  const Character({
    required this.name,
    required this.gender,
    required this.birthYear,
    required this.province,
    this.background = 'menengah',
  });

  final String name;
  final Gender gender;
  final int birthYear;
  final String province;
  final String background;

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.name,
        'birthYear': birthYear,
        'province': province,
        'background': background,
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        name: json['name'] as String,
        gender: Gender.values.byName(json['gender'] as String),
        birthYear: json['birthYear'] as int,
        province: json['province'] as String,
        background: json['background'] as String? ?? 'menengah',
      );
}
