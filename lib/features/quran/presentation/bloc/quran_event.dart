import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurahListEvent extends QuranEvent {
  const LoadSurahListEvent();
}

class LoadSurahContentEvent extends QuranEvent {
  final int surahNumber;

  const LoadSurahContentEvent(this.surahNumber);

  @override
  List<Object?> get props => [surahNumber];
}
