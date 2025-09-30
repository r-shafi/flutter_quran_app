import '../../domain/entities/surah.dart';

class SurahListModel {
  SurahListModel({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final List<SurahModel> data;

  factory SurahListModel.fromMap(Map<String, dynamic> json) => SurahListModel(
        code: json["code"],
        status: json["status"],
        data: List<SurahModel>.from(
            json["data"].map((x) => SurahModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class SurahModel extends Surah {
  const SurahModel({
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required int numberOfAyahs,
    required String revelationType,
  }) : super(
          number: number,
          name: name,
          englishName: englishName,
          englishNameTranslation: englishNameTranslation,
          numberOfAyahs: numberOfAyahs,
          revelationType: revelationType,
        );

  factory SurahModel.fromMap(Map<String, dynamic> json) => SurahModel(
        number: json["number"],
        name: json["name"],
        englishName: json["englishName"],
        englishNameTranslation: json["englishNameTranslation"],
        numberOfAyahs: json["numberOfAyahs"],
        revelationType: json["revelationType"],
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "name": name,
        "englishName": englishName,
        "englishNameTranslation": englishNameTranslation,
        "numberOfAyahs": numberOfAyahs,
        "revelationType": revelationType,
      };
  
  factory SurahModel.fromEntity(Surah surah) => SurahModel(
        number: surah.number,
        name: surah.name,
        englishName: surah.englishName,
        englishNameTranslation: surah.englishNameTranslation,
        numberOfAyahs: surah.numberOfAyahs,
        revelationType: surah.revelationType,
      );
}
