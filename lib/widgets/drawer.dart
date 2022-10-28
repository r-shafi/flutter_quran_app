import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/models/audio_list.dart';

Future<AudioListModel> fetchVoiceList() async {
  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/edition/format/audio'),
  );

  if (response.statusCode == 200) {
    return AudioListModel.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  // TODO: shared preferences
  late Future<AudioListModel> _futureVoiceList;
  final player = AudioPlayer();

  bool isPlaying = false;
  String lastIdentifier = '';

  void audioPlaybackController(String identifier) async {
    if (player.playing && lastIdentifier == identifier) {
      player.pause();
      setState(() {
        isPlaying = false;
      });
      return;
    }

    if (player.playing) {
      player.stop();
      setState(() {
        isPlaying = false;
      });
    }

    setState(() {
      isPlaying = true;
      lastIdentifier = identifier;
    });

    await player.setUrl(
        'https://cdn.islamic.network/quran/audio/128/$identifier/262.mp3');

    await player.play();
  }

  @override
  void initState() {
    super.initState();
    _futureVoiceList = fetchVoiceList();
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _futureVoiceList,
        builder: (context, AsyncSnapshot<AudioListModel> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor:
                      lastIdentifier == snapshot.data!.data[index].identifier
                          ? Colors.deepOrange
                          : null,
                  onTap: () => audioPlaybackController(
                    snapshot.data!.data[index].identifier,
                  ),
                  title: Text(snapshot.data!.data[index].englishName),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3
