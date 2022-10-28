class AudioListModel {
  AudioListModel({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final List<AudioModel> data;

  factory AudioListModel.fromJson(Map<String, dynamic> json) => AudioListModel(
        code: json["code"],
        status: json["status"],
        data: List<AudioModel>.from(
          json["data"].map(
            (x) => AudioModel.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "data": List<dynamic>.from(
          data.map(
            (x) => x.toJson(),
          ),
        ),
      };
}

class AudioModel {
  AudioModel({
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

  factory AudioModel.fromJson(Map<String, dynamic> json) => AudioModel(
        identifier: json["identifier"],
        language: json["language"],
        name: json["name"],
        englishName: json["englishName"],
        format: json["format"],
        type: json["type"],
        direction: json["direction"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "language": language,
        "name": name,
        "englishName": englishName,
        "format": format,
        "type": type,
        "direction": direction,
      };
}
