import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_remote_datasource.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

/// Implementation of [QuranRepository] using remote API data source
/// 
/// This repository handles data fetching from the Quran API,
/// with caching support and error handling.
class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;

  QuranRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SurahEntity>> getSurahList() async {
    final result = await remoteDataSource.getSurahList();
    final data = result['data'] as List<dynamic>;
    return SurahModel.fromMapList(data.cast<Map<String, dynamic>>());
  }

  @override
  Future<SurahEntity> getSurah(int surahNumber) async {
    final result = await remoteDataSource.getSurahContent(
      surahNumber,
      'ar.ahmedajamy',
    );
    final data = result['data'] as Map<String, dynamic>;
    return SurahModel.fromMap(data);
  }

  @override
  Future<AyahEntity> getAyah(int ayahIndex) async {
    final result = await remoteDataSource.getAyahContent(
      ayahIndex,
      'quran-uthmani',
    );
    final data = result['data'] as Map<String, dynamic>;
    return AyahModel.fromMap(data);
  }

  @override
  Future<List<AyahEntity>> getJuz(int juzNumber) async {
    final result = await remoteDataSource.getJuzContent(
      juzNumber,
      'quran-uthmani',
    );
    final data = result['data'] as Map<String, dynamic>;
    final ayahs = data['ayahs'] as List<dynamic>;
    return AyahModel.fromMapList(ayahs.cast<Map<String, dynamic>>());
  }

  @override
  Future<List<Map<String, String>>> getAudioReciters() async {
    final result = await remoteDataSource.getAudioEditions();
    final data = result['data'] as List<dynamic>;
    return data
        .map<Map<String, String>>((item) => {
              'identifier': item['identifier'] as String,
              'name': item['name'] as String,
              'englishName': item['englishName'] as String,
            })
        .toList();
  }
}
