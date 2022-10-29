import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class VoicePicker extends StatefulWidget {
  const VoicePicker({Key? key}) : super(key: key);

  @override
  State<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<VoicePicker> {
  late Future<AudioListModel> _futureVoiceList;

  @override
  void initState() {
    super.initState();
    _futureVoiceList = fetchVoiceList();
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
            return GridView.count(
              crossAxisCount: 2,
              children: snapshot.data!.data.map((e) {
                return Text(e.englishName);
              }).toList(),
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
