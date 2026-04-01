/// Ayah entity representing a verse in the Quran
/// 
/// This is a pure Dart class without any serialization logic.
/// Used across the application as the domain model.
class AyahEntity {
  final int number;
  final int numberInSurah;
  final int juz;
  final int hizb;
  final int rub;
  final String text;
  final String? audioUrl;

  const AyahEntity({
    required this.number,
    required this.numberInSurah,
    required this.juz,
    required this.hizb,
    required this.rub,
    required this.text,
    this.audioUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahEntity &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          numberInSurah == other.numberInSurah &&
          juz == other.juz &&
          hizb == other.hizb &&
          rub == other.rub &&
          text == other.text &&
          audioUrl == other.audioUrl;

  @override
  int get hashCode => Object.hash(
        number,
        numberInSurah,
        juz,
        hizb,
        rub,
        text,
        audioUrl,
      );

  @override
  String toString() => 'AyahEntity(number: $number, numberInSurah: $numberInSurah)';
}
