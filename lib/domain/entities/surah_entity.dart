/// Surah entity representing a chapter in the Quran
/// 
/// This is a pure Dart class without any serialization logic.
/// Used across the application as the domain model.
class SurahEntity {
  final int number;
  final String name;
  final String englishName;
  final String? englishNameTranslation;
  final int numberOfAyahs;
  final String? revelationType;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    this.englishNameTranslation,
    required this.numberOfAyahs,
    this.revelationType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahEntity &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          name == other.name &&
          englishName == other.englishName &&
          englishNameTranslation == other.englishNameTranslation &&
          numberOfAyahs == other.numberOfAyahs &&
          revelationType == other.revelationType;

  @override
  int get hashCode => Object.hash(
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType,
      );

  @override
  String toString() => 'SurahEntity(number: $number, name: $name, englishName: $englishName)';
}
