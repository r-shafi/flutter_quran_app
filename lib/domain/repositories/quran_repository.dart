import '../entities/surah_entity.dart';
import '../entities/ayah_entity.dart';

/// Abstract repository interface for Quran data access
/// 
/// This interface defines the contract for accessing Quran data.
/// Implementations can use different data sources (API, local database, cache).
abstract class QuranRepository {
  const QuranRepository();

  /// Get the list of all Surahs
  /// 
  /// Returns a list of [SurahEntity] objects.
  /// Throws [Failure] if the operation fails.
  Future<List<SurahEntity>> getSurahList();

  /// Get a specific Surah by its number
  /// 
  /// Returns a [SurahEntity] with its Ayahs.
  /// Throws [Failure] if the Surah is not found or operation fails.
  Future<SurahEntity> getSurah(int surahNumber);

  /// Get a specific Ayah by its global index (1-6236)
  /// 
  /// Returns an [AyahEntity] object.
  /// Throws [Failure] if the Ayah is not found or operation fails.
  Future<AyahEntity> getAyah(int ayahIndex);

  /// Get a Juz by its number (1-30)
  /// 
  /// Returns a list of [AyahEntity] objects in the Juz.
  /// Throws [Failure] if the Juz is not found or operation fails.
  Future<List<AyahEntity>> getJuz(int juzNumber);

  /// Get available audio reciters
  /// 
  /// Returns a list of reciter identifiers and names.
  /// Throws [Failure] if the operation fails.
  Future<List<Map<String, String>>> getAudioReciters();
}
