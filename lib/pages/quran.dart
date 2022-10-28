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
    Uri.parse('http://api.alquran.cloud/v1/surah/$id/ar.ahmedajamy'),
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
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: isPlaying || lastTrack != 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      if (lastTrack > 1) {
                        audioPlaybackController(lastTrack - 1);
                      }
                    },
                    icon: const Icon(Icons.skip_previous_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      player.seekToPrevious();
                    },
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    onPressed: () {
                      player.playing ? player.pause() : player.play();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      player.seekToNext();
                    },
                    icon: const Icon(Icons.skip_next),
                  ),
                  IconButton(
                    onPressed: () {
                      if (lastTrack < 114) {
                        audioPlaybackController(lastTrack + 1);
                      }
                    },
                    icon: const Icon(Icons.skip_next_outlined),
                  ),
                ],
              )
            : null,
      ),
      appBar: AppBar(
        title: const Text('Quran Audio'),
      ),
      body: FutureBuilder(
        future: _futureSurahList,
        builder: (context, AsyncSnapshot<SurahListModel> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data!.data[index].englishName),
                  subtitle: Text(snapshot.data!.data[index].name),
                  trailing: IconButton(
                    onPressed: () {
                      audioPlaybackController(
                        snapshot.data!.data[index].number,
                      );
                    },
                    icon: Icon(
                      lastTrack == snapshot.data!.data[index].number
                          ? isPlaying
                              ? Icons.pause
                              : Icons.play_arrow
                          : Icons.play_arrow,
                    ),
                  ),
                );
              },
            );
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
