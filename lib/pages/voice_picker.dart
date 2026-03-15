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
  final TextEditingController _searchController = TextEditingController();

  String _selectedVoice = '';
  String _pendingVoice = '';
  String _playingVoice = '';
  String _searchQuery = '';

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
    _searchController.dispose();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(String identifier) async {
    if (_player.playing && identifier == _playingVoice) {
      await _player.pause();
      return;
    }

    if (!_player.playing && identifier == _playingVoice) {
      await _player.play();
      return;
    }

    if (_player.playing) {
      await _player.stop();
    }

    setState(() {
      _playingVoice = identifier;
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

  List<AudioModel> _filteredVoices(List<AudioModel> voices) {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return voices;
    }

    return voices.where((voice) {
      return voice.englishName.toLowerCase().contains(normalized) ||
          voice.identifier.toLowerCase().contains(normalized);
    }).toList();
  }

  Widget _buildVoiceTile(AudioModel voice, TextTheme textTheme) {
    final isPending = _pendingVoice == voice.identifier;
    final isApplied = _selectedVoice == voice.identifier;
    final isPlaying = _playingVoice == voice.identifier && _player.playing;

    return PressableCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      accentLeft: isPending,
      onTap: () {
        setState(() {
          _pendingVoice = voice.identifier;
        });
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice.englishName,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isApplied ? 'Current voice' : 'Tap to select',
                  style: textTheme.labelSmall?.copyWith(
                    color: isApplied
                        ? context.palette.goldPrimary
                        : context.palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isPlaying ? 'Pause preview' : 'Play preview',
            onPressed: () => _preview(voice.identifier),
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: isPlaying
                  ? context.palette.goldPrimary
                  : context.palette.goldMuted,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AnimatedContainer(
            duration: AppDurations.pressScale,
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPending
                    ? context.palette.goldPrimary
                    : context.palette.textMuted,
              ),
              color: isPending
                  ? context.palette.goldPrimary
                  : AppColorValues.transparent,
            ),
            child: isPending
                ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: context.palette.bgDeep,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Voice Picker'),
        showBack: true,
      ),
      body: FutureBuilder<AudioListModel>(
        future: _futureVoiceList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final voices = _filteredVoices(snapshot.data!.data);
          final selectedVoiceName = snapshot.data!.data
              .where((voice) => voice.identifier == _pendingVoice)
              .map((voice) => voice.englishName)
              .cast<String?>()
              .firstWhere(
                (name) => name != null,
                orElse: () => null,
              );

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      const SectionHeader(title: 'Choose Reciter'),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search by reciter name',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: context.palette.textMuted,
                            ),
                            icon: Icon(
                              Icons.search_rounded,
                              color: context.palette.goldMuted,
                            ),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: voices.isEmpty
                            ? Center(
                                child: Text(
                                  'No reciters match your search.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: context.palette.textMuted,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: voices.length,
                                itemBuilder: (context, index) {
                                  return _buildVoiceTile(
                                    voices[index],
                                    textTheme,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.palette.bgDeep,
                  border: Border(
                    top: BorderSide(
                      color: context.palette.goldMuted.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedVoiceName == null
                            ? 'No reciter selected yet'
                            : 'Selected: $selectedVoiceName',
                        style: textTheme.labelSmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GoldButton(
                        label: 'Confirm Selection',
                        onPressed:
                            _pendingVoice.isEmpty ? null : _confirmSelection,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
