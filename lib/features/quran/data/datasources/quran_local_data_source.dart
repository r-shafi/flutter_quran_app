import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_list.dart';

abstract class QuranLocalDataSource {
  Future<List<SurahModel>>? getCachedSurahList();
  Future<void> cacheSurahList(List<SurahModel> surahs);
}

@LazySingleton(as: QuranLocalDataSource)
class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const cachedSurahListKey = 'CACHED_SURAH_LIST';

  QuranLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<SurahModel>>? getCachedSurahList() async {
    final jsonString = sharedPreferences.getString(cachedSurahListKey);
    if (jsonString != null) {
      final data = SurahListModel.fromMap(jsonDecode(jsonString));
      return data.data;
    }
    return null;
  }

  @override
  Future<void> cacheSurahList(List<SurahModel> surahs) async {
    final surahListModel = SurahListModel(
      code: 200,
      status: 'OK',
      data: surahs,
    );
    await sharedPreferences.setString(
      cachedSurahListKey,
      json.encode(surahListModel.toMap()),
    );
  }
}
