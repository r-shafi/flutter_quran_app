class PrayerTimeModel {
  PrayerTimeModel({
    required this.code,
    required this.status,
    required this.data,
  });

  final int code;
  final String status;
  final List<SingleDayModel> data;

  factory PrayerTimeModel.fromMap(Map<String, dynamic> json) => PrayerTimeModel(
        code: json["code"],
        status: json["status"],
        data: List<SingleDayModel>.from(
            json["data"].map((x) => SingleDayModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "code": code,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class SingleDayModel {
  SingleDayModel({
    required this.timings,
    required this.date,
    required this.meta,
  });

  final Timings timings;
  final Date date;
  final Meta meta;

  factory SingleDayModel.fromMap(Map<String, dynamic> json) => SingleDayModel(
        timings: Timings.fromMap(json["timings"]),
        date: Date.fromMap(json["date"]),
        meta: Meta.fromMap(json["meta"]),
      );

  Map<String, dynamic> toMap() => {
        "timings": timings.toMap(),
        "date": date.toMap(),
        "meta": meta.toMap(),
      };
}

class Date {
  Date({
    required this.readable,
    required this.timestamp,
    required this.gregorian,
    required this.hijri,
  });

  final String readable;
  final String timestamp;
  final Gregorian gregorian;
  final Hijri hijri;

  factory Date.fromMap(Map<String, dynamic> json) => Date(
        readable: json["readable"],
        timestamp: json["timestamp"],
        gregorian: Gregorian.fromMap(json["gregorian"]),
        hijri: Hijri.fromMap(json["hijri"]),
      );

  Map<String, dynamic> toMap() => {
        "readable": readable,
        "timestamp": timestamp,
        "gregorian": gregorian.toMap(),
        "hijri": hijri.toMap(),
      };
}

class Gregorian {
  Gregorian({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.designation,
  });

  final String date;
  final dynamic format;
  final String day;
  final GregorianWeekday weekday;
  final GregorianMonth month;
  final String year;
  final Designation designation;

  factory Gregorian.fromMap(Map<String, dynamic> json) => Gregorian(
        date: json["date"],
        format: json["format"],
        day: json["day"],
        weekday: GregorianWeekday.fromMap(json["weekday"]),
        month: GregorianMonth.fromMap(json["month"]),
        year: json["year"],
        designation: Designation.fromMap(json["designation"]),
      );

  Map<String, dynamic> toMap() => {
        "date": date,
        "format": format,
        "day": day,
        "weekday": weekday.toMap(),
        "month": month.toMap(),
        "year": year,
        "designation": designation.toMap(),
      };
}

class Designation {
  Designation({
    required this.abbreviated,
    required this.expanded,
  });

  final dynamic abbreviated;
  final dynamic expanded;

  factory Designation.fromMap(Map<String, dynamic> json) => Designation(
        abbreviated: json["abbreviated"],
        expanded: json["expanded"],
      );

  Map<String, dynamic> toMap() => {
        "abbreviated": abbreviated,
        "expanded": expanded,
      };
}

class GregorianMonth {
  GregorianMonth({
    required this.number,
    required this.en,
  });

  final int number;
  final dynamic en;

  factory GregorianMonth.fromMap(Map<String, dynamic> json) => GregorianMonth(
        number: json["number"],
        en: json["en"],
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "en": en,
      };
}

class GregorianWeekday {
  GregorianWeekday({
    required this.en,
  });

  final String en;

  factory GregorianWeekday.fromMap(Map<String, dynamic> json) =>
      GregorianWeekday(
        en: json["en"],
      );

  Map<String, dynamic> toMap() => {
        "en": en,
      };
}

class Hijri {
  Hijri({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
    required this.designation,
    required this.holidays,
  });

  final String date;
  final dynamic format;
  final String day;
  final HijriWeekday weekday;
  final HijriMonth month;
  final String year;
  final Designation designation;
  final List<String> holidays;

  factory Hijri.fromMap(Map<String, dynamic> json) => Hijri(
        date: json["date"],
        format: json["format"],
        day: json["day"],
        weekday: HijriWeekday.fromMap(json["weekday"]),
        month: HijriMonth.fromMap(json["month"]),
        year: json["year"],
        designation: Designation.fromMap(json["designation"]),
        holidays: List<String>.from(json["holidays"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "date": date,
        "format": format,
        "day": day,
        "weekday": weekday.toMap(),
        "month": month.toMap(),
        "year": year,
        "designation": designation.toMap(),
        "holidays": List<dynamic>.from(holidays.map((x) => x)),
      };
}

class HijriMonth {
  HijriMonth({
    required this.number,
    required this.en,
    required this.ar,
  });

  final int number;
  final dynamic en;
  final dynamic ar;

  factory HijriMonth.fromMap(Map<String, dynamic> json) => HijriMonth(
        number: json["number"],
        en: json["en"],
        ar: json["ar"],
      );

  Map<String, dynamic> toMap() => {
        "number": number,
        "en": en,
        "ar": ar,
      };
}

class HijriWeekday {
  HijriWeekday({
    required this.en,
    required this.ar,
  });

  final String en;
  final String ar;

  factory HijriWeekday.fromMap(Map<String, dynamic> json) => HijriWeekday(
        en: json["en"],
        ar: json["ar"],
      );

  Map<String, dynamic> toMap() => {
        "en": en,
        "ar": ar,
      };
}

class Meta {
  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.method,
    required this.latitudeAdjustmentMethod,
    required this.midnightMode,
    required this.school,
    required this.offset,
  });

  final double latitude;
  final double longitude;
  final dynamic timezone;
  final Method method;
  final dynamic latitudeAdjustmentMethod;
  final dynamic midnightMode;
  final dynamic school;
  final Map<String, int> offset;

  factory Meta.fromMap(Map<String, dynamic> json) => Meta(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        timezone: json["timezone"],
        method: Method.fromMap(json["method"]),
        latitudeAdjustmentMethod: json["latitudeAdjustmentMethod"],
        midnightMode: json["midnightMode"],
        school: json["school"],
        offset:
            Map.from(json["offset"]).map((k, v) => MapEntry<String, int>(k, v)),
      );

  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "method": method.toMap(),
        "latitudeAdjustmentMethod": latitudeAdjustmentMethod,
        "midnightMode": midnightMode,
        "school": school,
        "offset":
            Map.from(offset).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class Method {
  Method({
    required this.id,
    required this.name,
    required this.params,
    required this.location,
  });

  final int id;
  final dynamic name;
  final Params params;
  final Location location;

  factory Method.fromMap(Map<String, dynamic> json) => Method(
        id: json["id"],
        name: json["name"],
        params: Params.fromMap(json["params"]),
        location: Location.fromMap(json["location"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "params": params.toMap(),
        "location": location.toMap(),
      };
}

class Location {
  Location({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory Location.fromMap(Map<String, dynamic> json) => Location(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class Params {
  Params({
    required this.fajr,
    required this.isha,
  });

  final int fajr;
  final int isha;

  factory Params.fromMap(Map<String, dynamic> json) => Params(
        fajr: json["Fajr"],
        isha: json["Isha"],
      );

  Map<String, dynamic> toMap() => {
        "Fajr": fajr,
        "Isha": isha,
      };
}

class Timings {
  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final String fajr;
  final String sunrise;
  final dynamic dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  factory Timings.fromMap(Map<String, dynamic> json) => Timings(
        fajr: json["Fajr"],
        sunrise: json["Sunrise"],
        dhuhr: json["Dhuhr"],
        asr: json["Asr"],
        maghrib: json["Maghrib"],
        isha: json["Isha"],
      );

  Map<String, dynamic> toMap() => {
        "Fajr": fajr,
        "Sunrise": sunrise,
        "Dhuhr": dhuhr,
        "Asr": asr,
        "Maghrib": maghrib,
        "Isha": isha,
      };
}
