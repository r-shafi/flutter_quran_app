import '../../domain/entities/surah_entity.dart';

/// Surah model with serialization support
/// 
/// Extends [SurahEntity] and adds fromMap/toMap methods for JSON serialization.
class SurahModel extends SurahEntity {
  const SurahModel({
    required super.number,
    required super.name,
    required super.englishName,
    super.englishNameTranslation,
    required super.numberOfAyahs,
    super.revelationType,
  });

  factory SurahModel.fromMap(Map<String, dynamic> data) {
    return SurahModel(
      number: data['number'] as int,
      name: data['name'] as String,
      englishName: data['englishName'] as String,
      englishNameTranslation: data['englishNameTranslation'] as String?,
      numberOfAyahs: data['numberOfAyahs'] as int,
      revelationType: data['revelationType'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
    };
  }

  /// Convert list of maps to list of models
  static List<SurahModel> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((item) => SurahModel.fromMap(item)).toList();
  }
}
