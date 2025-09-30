import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_surah_content.dart';
import '../../domain/usecases/get_surah_list.dart';
import 'quran_event.dart';
import 'quran_state.dart';

@injectable
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetSurahList getSurahList;
  final GetSurahContent getSurahContent;

  QuranBloc({
    required this.getSurahList,
    required this.getSurahContent,
  }) : super(const QuranInitial()) {
    on<LoadSurahListEvent>(_onLoadSurahList);
    on<LoadSurahContentEvent>(_onLoadSurahContent);
  }

  Future<void> _onLoadSurahList(
    LoadSurahListEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(const QuranLoading());

    final result = await getSurahList();

    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (surahs) => emit(SurahListLoaded(surahs)),
    );
  }

  Future<void> _onLoadSurahContent(
    LoadSurahContentEvent event,
    Emitter<QuranState> emit,
  ) async {
    emit(const QuranLoading());

    final result = await getSurahContent(event.surahNumber);

    result.fold(
      (failure) => emit(QuranError(failure.message)),
      (ayahs) => emit(SurahContentLoaded(
        ayahs: ayahs,
        surahNumber: event.surahNumber,
      )),
    );
  }
}
