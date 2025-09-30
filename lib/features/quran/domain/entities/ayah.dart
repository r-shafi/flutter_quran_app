import 'package:equatable/equatable.dart';

class Ayah extends Equatable {
  final int number;
  final String audio;
  final String text;
  final int numberInSurah;
  final int juz;
  final int page;

  const Ayah({
    required this.number,
    required this.audio,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.page,
  });

  @override
  List<Object?> get props => [
        number,
        audio,
        text,
        numberInSurah,
        juz,
        page,
      ];
}
