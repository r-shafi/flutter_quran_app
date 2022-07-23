import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import './../models/surah_content.dart';
import './../models/surah_list.dart';

Future<SurahListModel> fetchSurahList() async {
  final response = await http.get(
    Uri.parse('http://api.alquran.cloud/v1/surah'),
  );

  if (response.statusCode == 200) {
    return SurahListModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

Future<SurahContentModel> fetchSurahContent(int id) async {
  final response = await http.get(
    Uri.parse('http://api.alquran.cloud/v1/surah/$id/ar.alafasy'),
  );

  if (response.statusCode == 200) {
    return SurahContentModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

class Quran extends StatefulWidget {
  const Quran({Key? key}) : super(key: key);

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  final player = AudioPlayer();

  late Future<SurahListModel> _futureSurahList;
  late Future<SurahContentModel> _futureSurahContent;

  late ConcatenatingAudioSource _playlist;

  int lastTrack = 0;
  bool isPlaying = false;

  void audioPlaybackController(int surah) {
    if (player.playing && lastTrack == surah) {
      player.pause();
      setState(() {
        isPlaying = false;
      });
      return;
    }

    if (!player.playing && lastTrack == surah) {
      player.play();
      setState(() {
        isPlaying = true;
      });
      return;
    }

    if (player.playing && lastTrack != surah) {
      player.stop();
      setState(() {
        isPlaying = false;
      });
    }

    _futureSurahContent = fetchSurahContent(surah);

    _futureSurahContent.then((content) async {
      _playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: content.data.ayahs
            .map((ayah) => AudioSource.uri(Uri.parse(ayah.audio)))
            .toList(),
      );

      await player.setAudioSource(_playlist);

      setState(() {
        isPlaying = true;
        lastTrack = surah;
      });

      await player.play();
    });
  }

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
                        trailing: IconButton(
                          icon: isPlaying && lastTrack == surah.number
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          onPressed: () {
                            audioPlaybackController(surah.number);
                          },
                        ),
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
