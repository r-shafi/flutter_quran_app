import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Remote data source for Quran API
/// 
/// Handles all network requests to the Quran API.
/// Implements caching strategy for better performance.
class QuranRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  QuranRemoteDataSource({
    required this.apiClient,
    required this.sharedPreferences,
  });

  /// Fetch Surah list from API with caching
  Future<Map<String, dynamic>> getSurahList() async {
    // Try cache first
    final cached = sharedPreferences.getString('surah_list_cache');
    if (cached != null) {
      try {
        return json.decode(cached) as Map<String, dynamic>;
      } catch (_) {
        // Cache corrupted, fetch from network
      }
    }

    // Fetch from network
    final result = await apiClient.get(ApiEndpoints.surahList());
    
    // Cache the result
    await sharedPreferences.setString('surah_list_cache', json.encode(result));
    
    return result;
  }

  /// Fetch Surah content from API
  Future<Map<String, dynamic>> getSurahContent(
    int surahNumber,
    String edition,
  ) async {
    final url = ApiEndpoints.surahContent(surahNumber, edition);
    return await apiClient.get(url);
  }

  /// Fetch Juz content from API
  Future<Map<String, dynamic>> getJuzContent(
    int juzNumber,
    String edition,
  ) async {
    final url = ApiEndpoints.juzContent(juzNumber, edition);
    return await apiClient.get(url);
  }

  /// Fetch Ayah content from API
  Future<Map<String, dynamic>> getAyahContent(
    int ayahIndex,
    String editions,
  ) async {
    final url = ApiEndpoints.ayahContent(ayahIndex, editions);
    return await apiClient.get(url);
  }

  /// Fetch audio editions from API
  Future<Map<String, dynamic>> getAudioEditions() async {
    final url = ApiEndpoints.audioEditions();
    return await apiClient.get(url);
  }
}
