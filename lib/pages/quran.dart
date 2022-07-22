import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/models/surah_list.dart';

Future<SurahListModel> fetchSurahList() async {
  final response = await http.get(
    Uri.parse('http://api.alquran.cloud/v1/surah'),
  );

  if (response.statusCode == 200) {
    return SurahListModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class Quran extends StatefulWidget {
  const Quran({Key? key}) : super(key: key);

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  late Future<SurahListModel> _futureSurahList;

  @override
  void initState() {
    super.initState();
    _futureSurahList = fetchSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Audio'),
      ),
      body: FutureBuilder(
        future: _futureSurahList,
        builder: (context, AsyncSnapshot<SurahListModel> snapshot) {
          if (snapshot.hasData) {
            return ListView(
                children: snapshot.data!.data
                    .map(
                      (surah) => ListTile(
                        title: Text(surah.englishName),
                        subtitle: Text(surah.name),
                        trailing: const Icon(Icons.play_arrow_sharp),
                      ),
                    )
                    .toList());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
