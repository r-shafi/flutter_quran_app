class SurahContentModel {
  SurahContentModel({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final Data data;

  factory SurahContentModel.fromMap(Map<String, dynamic> json) =>
      SurahContentModel(
        code: json["code"],
        status: json["status"],
        data: Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "status": status,
        "data": data.toMap(),
      };
}

class Data {
  Data({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
    required this.edition,
  });

  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<AyahModel> ayahs;
  final Edition edition;

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        number: json["number"],
        name: json["name"],
        englishName: json["englishName"],
        englishNameTranslation: json["englishNameTranslation"],
        revelationType: json["revelationType"],
        numberOfAyahs: json["numberOfAyahs"],
        ayahs: List<AyahModel>.from(json["ayahs"].map((x) => AyahModel.fromMap(x))),
        edition: Edition.fromMap(json["edition"]),
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "name": name,
        "englishName": englishName,
        "englishNameTranslation": englishNameTranslation,
        "revelationType": revelationType,
        "numberOfAyahs": numberOfAyahs,
        "ayahs": List<dynamic>.from(ayahs.map((x) => x.toMap())),
        "edition": edition.toMap(),
      };
}

import '../../domain/entities/ayah.dart' as entity;

class AyahModel extends entity.Ayah {
  final List<String> audioSecondary;
  final int manzil;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const AyahModel({
    required int number,
    required String audio,
    required this.audioSecondary,
    required String text,
    required int numberInSurah,
    required int juz,
    required this.manzil,
    required int page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  }) : super(
          number: number,
          audio: audio,
          text: text,
          numberInSurah: numberInSurah,
          juz: juz,
          page: page,
        );

  factory AyahModel.fromMap(Map<String, dynamic> json) => AyahModel(
        number: json["number"],
        audio: json["audio"],
        audioSecondary: List<String>.from(json["audioSecondary"].map((x) => x)),
        text: json["text"],
        numberInSurah: json["numberInSurah"],
        juz: json["juz"],
        manzil: json["manzil"],
        page: json["page"],
        ruku: json["ruku"],
        hizbQuarter: json["hizbQuarter"],
        sajda: json["sajda"],
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "audio": audio,
        "audioSecondary": List<dynamic>.from(audioSecondary.map((x) => x)),
        "text": text,
        "numberInSurah": numberInSurah,
        "juz": juz,
        "manzil": manzil,
        "page": page,
        "ruku": ruku,
        "hizbQuarter": hizbQuarter,
        "sajda": sajda,
      };
}

class Edition {
  Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    required this.direction,
  });

  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;
  final dynamic direction;

  factory Edition.fromMap(Map<String, dynamic> json) => Edition(
        identifier: json["identifier"],
        language: json["language"],
        name: json["name"],
        englishName: json["englishName"],
        format: json["format"],
        type: json["type"],
        direction: json["direction"],
      );

  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "language": language,
        "name": name,
        "englishName": englishName,
        "format": format,
        "type": type,
        "direction": direction,
      };
}
