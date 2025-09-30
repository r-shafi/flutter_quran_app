import 'package:dartz/dartz.dart';
import '../entities/ayah.dart';
import '../entities/surah.dart';
import '../../../../core/errors/failures.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getSurahList();
  Future<Either<Failure, List<Ayah>>> getSurahContent(int surahNumber);
}
