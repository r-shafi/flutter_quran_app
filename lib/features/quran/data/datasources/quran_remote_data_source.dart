import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_content.dart';
import '../models/surah_list.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahModel>> getSurahList();
  Future<List<AyahModel>> getSurahContent(int surahNumber, String voice);
}

@LazySingleton(as: QuranRemoteDataSource)
class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  QuranRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<List<SurahModel>> getSurahList() async {
    final response = await client.get(
      Uri.parse('http://api.alquran.cloud/v1/surah'),
    );

    if (response.statusCode == 200) {
      final data = SurahListModel.fromMap(json.decode(response.body));
      return data.data;
    } else {
      throw Exception('Failed to load surah list');
    }
  }

  @override
  Future<List<AyahModel>> getSurahContent(int surahNumber, String voice) async {
    final response = await client.get(
      Uri.parse('http://api.alquran.cloud/v1/surah/$surahNumber/$voice'),
    );

    if (response.statusCode == 200) {
      final data = SurahContentModel.fromMap(json.decode(response.body));
      return data.data.ayahs;
    } else {
      throw Exception('Failed to load surah content');
    }
  }
}
