import 'package:equatable/equatable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {
  const QuranInitial();
}

class QuranLoading extends QuranState {
  const QuranLoading();
}

class SurahListLoaded extends QuranState {
  final List<Surah> surahs;

  const SurahListLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class SurahContentLoaded extends QuranState {
  final List<Ayah> ayahs;
  final int surahNumber;

  const SurahContentLoaded({
    required this.ayahs,
    required this.surahNumber,
  });

  @override
  List<Object?> get props => [ayahs, surahNumber];
}

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}
