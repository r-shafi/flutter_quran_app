/// Centralized API endpoint configuration
/// 
/// This file contains all API endpoints used in the application.
/// Primary and fallback endpoints are provided for reliability.
/// 
/// Data Sources:
/// - Quran API: https://api.alquran.cloud (Islamic Network)
/// - Prayer Times: https://api.aladhan.com
/// - Hadith: https://api.hadith.gading.dev
/// 
/// All APIs are FOSS-friendly and require no authentication.
class ApiEndpoints {
  ApiEndpoints._();

  // === Quran API (Islamic Network) ===
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String quranApiFallback = 'https://api.alquran.cloud/v1';
  
  // Quran endpoints
  static String surahList() => '$quranApiBase/surah';
  static String surahContent(int surahNumber, String edition) => 
      '$quranApiBase/surah/$surahNumber/$edition';
  static String juzContent(int juzNumber, String edition) => 
      '$quranApiBase/juz/$juzNumber/$edition';
  static String ayahContent(int ayahIndex, String editions) => 
      '$quranApiBase/ayah/$ayahIndex/editions/$editions';
  static String audioEditions() => '$quranApiBase/edition/format/audio';
  
  // === Prayer Times API ===
  static const String prayerTimesApiBase = 'https://api.aladhan.com/v1';
  
  // Prayer times endpoints
  static String hijriCalendarByCity(String city, String country) => 
      '$prayerTimesApiBase/hijriCalendarByCity?city=$city&country=$country';
  static String timingsByCity(String city, String country, {String? method}) {
    final params = <String, String>{
      'city': city,
      'country': country,
      if (method != null) 'method': method,
    };
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$prayerTimesApiBase/timingsByCity?$queryString';
  }
  
  // === Hadith API ===
  static const String hadithApiBase = 'https://api.hadith.gading.dev';
  static const String hadithApiCdn = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  
  // Hadith endpoints
  static String hadithBooks() => '$hadithApiBase/books';
  static String hadithBookRange(String bookId, String range) => 
      '$hadithApiBase/books/$bookId?range=$range';
  static String hadithEdition(String editionId) => 
      '$hadithApiCdn/editions/$editionId.json';
  
  // === Audio CDN ===
  static const String audioCdnBase = 'https://cdn.islamic.network/quran/audio';
  
  // Audio endpoint
  static String audioUrl(String identifier, int quality, int ayahNumber) => 
      '$audioCdnBase/$quality/$identifier/$ayahNumber.mp3';
  
  // === Edition Identifiers ===
  /// Common Quran edition identifiers
  static const String quranUthmani = 'quran-uthmani';
  static const String quranIndopak = 'quran-indopak';
  static const String translationEnglishSahih = 'en.sahih';
  static const String translationUrduJalandhry = 'ur.jalandhry';
  static const String translationIndonesian = 'id.indonesian';
  
  /// Common audio reciter identifiers
  static const String audioAhmedAjamy = 'ar.ahmedajamy';
  static const String audioMisharyRashid = 'ar.alafasy';
  static const String audioAbdulRahmanAlSudais = 'ar.abdulrahmaansudais';
  static const String audioSaadAlGhamdi = 'ar.saadalkhamdi';
  static const String audioHusary = 'ar.husary';
  
  // === API Headers ===
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // === Timeout Durations ===
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
