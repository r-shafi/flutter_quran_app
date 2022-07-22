class SurahListModel {
  SurahListModel({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final List<SurahMetaModel> data;

  factory SurahListModel.fromMap(Map<String, dynamic> json) => SurahListModel(
        code: json["code"],
        status: json["status"],
        data: List<SurahMetaModel>.from(
            json["data"].map((x) => SurahMetaModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class SurahMetaModel {
  SurahMetaModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  factory SurahMetaModel.fromMap(Map<String, dynamic> json) => SurahMetaModel(
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
}
