import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ayah.dart';
import '../repositories/quran_repository.dart';

@lazySingleton
class GetSurahContent {
  final QuranRepository repository;

  GetSurahContent(this.repository);

  Future<Either<Failure, List<Ayah>>> call(int surahNumber) async {
    return await repository.getSurahContent(surahNumber);
  }
}
