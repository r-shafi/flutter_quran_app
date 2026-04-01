import '../../domain/entities/ayah_entity.dart';

/// Ayah model with serialization support
/// 
/// Extends [AyahEntity] and adds fromMap/toMap methods for JSON serialization.
class AyahModel extends AyahEntity {
  const AyahModel({
    required super.number,
    required super.numberInSurah,
    required super.juz,
    required super.hizb,
    required super.rub,
    required super.text,
    super.audioUrl,
  });

  factory AyahModel.fromMap(Map<String, dynamic> data) {
    return AyahModel(
      number: data['number'] as int,
      numberInSurah: data['numberInSurah'] as int,
      juz: data['juz'] as int,
      hizb: data['hizb'] as int,
      rub: data['rub'] as int,
      text: data['text'] as String,
      audioUrl: data['audio'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'hizb': hizb,
      'rub': rub,
      'text': text,
      'audio': audioUrl,
    };
  }

  /// Convert list of maps to list of models
  static List<AyahModel> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((item) => AyahModel.fromMap(item)).toList();
  }
}
