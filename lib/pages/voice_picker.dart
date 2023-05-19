import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/models/audio_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<AudioListModel> fetchVoiceList() async {
  final SharedPreferences prefs = await _prefs;
  final String? voiceList = prefs.getString('voiceList');

  if (voiceList != null) {
    return AudioListModel.fromJson(jsonDecode(voiceList));
  }

  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/edition/format/audio'),
  );

  if (response.statusCode == 200) {
    prefs.setString('voiceList', response.body);
    return AudioListModel.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

class VoicePicker extends StatefulWidget {
  const VoicePicker({Key? key}) : super(key: key);

  @override
  State<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<VoicePicker> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<AudioListModel> _futureVoiceList;
  final player = AudioPlayer();

  String selectedVoice = '';

  @override
  void initState() {
    super.initState();
    _futureVoiceList = fetchVoiceList();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        selectedVoice = prefs.getString('selectedVoice') ?? '';
      });
    });
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  void playAudio(String identifier) async {
    if (player.playing && identifier == selectedVoice) {
      player.pause();
      return;
    } else if (!player.playing && identifier == selectedVoice) {
      player.play();
      return;
    }

    if (player.playing) {
      player.stop();
    }

    setState(() {
      selectedVoice = identifier;
    });

    _prefs.then((SharedPreferences prefs) {
      prefs.setString('selectedVoice', identifier);
    });

    try {
      await player.setUrl(
        "https://cdn.islamic.network/quran/audio/128/$identifier/262.mp3",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text(
            'Something went wrong! Try Selecting Another Voice',
          ),
        ),
      );
      return;
    }

    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Qari Voice'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _futureVoiceList,
        builder: ((context, AsyncSnapshot<AudioListModel> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 16 / 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: snapshot.data!.data.map((voice) {
                  return GestureDetector(
                    onTap: () => playAudio(voice.identifier),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedVoice == voice.identifier
                            ? Colors.pink
                            : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          voice.englishName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selectedVoice == voice.identifier
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      ),
    );
  }
}
