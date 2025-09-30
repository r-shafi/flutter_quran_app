import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';
import '../datasources/quran_remote_data_source.dart';

@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;
  final QuranLocalDataSource localDataSource;

  QuranRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Surah>>> getSurahList() async {
    try {
      // Try to get from cache first
      final cachedList = await localDataSource.getCachedSurahList();
      if (cachedList != null && cachedList.isNotEmpty) {
        return Right(cachedList);
      }

      // If not in cache, fetch from remote
      final remoteList = await remoteDataSource.getSurahList();
      
      // Cache the result
      await localDataSource.cacheSurahList(remoteList);
      
      return Right(remoteList);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Ayah>>> getSurahContent(int surahNumber) async {
    try {
      // For now, using default voice. This can be made dynamic later
      const defaultVoice = 'ar.ahmedajamy';
      final ayahs = await remoteDataSource.getSurahContent(surahNumber, defaultVoice);
      return Right(ayahs);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
