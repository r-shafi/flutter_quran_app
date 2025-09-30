import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/surah.dart';
import '../repositories/quran_repository.dart';

@lazySingleton
class GetSurahList {
  final QuranRepository repository;

  GetSurahList(this.repository);

  Future<Either<Failure, List<Surah>>> call() async {
    return await repository.getSurahList();
  }
}
