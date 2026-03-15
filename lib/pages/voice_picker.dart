import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/models/audio_list.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<AudioListModel> fetchVoiceList() async {
  final prefs = await _prefs;
  final cached = prefs.getString('voiceList');

  if (cached != null) {
    return AudioListModel.fromJson(jsonDecode(cached));
  }

  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/edition/format/audio'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load voices');
  }

  await prefs.setString('voiceList', response.body);
  return AudioListModel.fromJson(jsonDecode(response.body));
}

class VoicePicker extends StatefulWidget {
  const VoicePicker({super.key});

  @override
  State<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<VoicePicker> {
  late final Future<AudioListModel> _futureVoiceList;
  final AudioPlayer _player = AudioPlayer();

  String _selectedVoice = '';
  String _pendingVoice = '';

  @override
  void initState() {
    super.initState();
    _futureVoiceList = fetchVoiceList();
    _prefs.then((prefs) {
      if (!mounted) return;
      setState(() {
        _selectedVoice = prefs.getString('selectedVoice') ?? '';
        _pendingVoice = _selectedVoice;
      });
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(String identifier) async {
    if (_player.playing && identifier == _pendingVoice) {
      await _player.pause();
      return;
    }

    if (!_player.playing && identifier == _pendingVoice) {
      await _player.play();
      return;
    }

    if (_player.playing) {
      await _player.stop();
    }

    setState(() {
      _pendingVoice = identifier;
    });

    try {
      await _player.setUrl(
        'https://cdn.islamic.network/quran/audio/128/$identifier/262.mp3',
      );
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong, try another reciter',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
  }

  Future<void> _confirmSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVoice', _pendingVoice);
    if (!mounted) return;
    setState(() {
      _selectedVoice = _pendingVoice;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Voice Picker'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: FutureBuilder<AudioListModel>(
          future: _futureVoiceList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const SectionHeader(title: 'Choose Reciter'),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (context, index) {
                        final voice = snapshot.data!.data[index];
                        final selected = _pendingVoice == voice.identifier;

                        return PressableCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          accentLeft: selected,
                          onTap: () => _preview(voice.identifier),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  voice.englishName,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                              Container(
                                width: AppSpacing.md,
                                height: AppSpacing.md,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? context.palette.goldPrimary
                                        : context.palette.textMuted,
                                  ),
                                  color: selected
                                      ? context.palette.goldPrimary
                                      : AppColorValues.transparent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  GoldButton(
                    label: 'Confirm Selection',
                    onPressed: _pendingVoice.isEmpty ? null : _confirmSelection,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
