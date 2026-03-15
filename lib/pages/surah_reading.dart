import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/main.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSurah {
  ReadingSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });

  final int number;
  final String name;
  final String englishName;
  final List<ReadingAyah> ayahs;
}

class ReadingAyah {
  ReadingAyah({
    required this.numberInSurah,
    required this.arabicText,
    required this.number,
    this.translationText,
  });

  final int numberInSurah;
  final String arabicText;
  final String? translationText;
  final int number;
}

class SurahReadingScreen extends StatefulWidget {
  const SurahReadingScreen({
    super.key,
    this.surahNumber,
    this.juzNumber,
    required this.surahName,
    required this.englishName,
    this.initialAyahNumber,
  });

  final int? surahNumber;
  final int? juzNumber;
  final String surahName;
  final String englishName;
  final int? initialAyahNumber;

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen>
    with SingleTickerProviderStateMixin {
  bool _showTranslation = false;
  ReadingSurah? _surahData;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _bookmarks = [];
  int _currentPlayingAyah = -1;
  String _selectedVoice = 'Default Qari';

  late final AnimationController _pulseController;
  StreamSubscription<int?>? _indexSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.ayahPulse,
    )..repeat(reverse: true);
    _loadData();
    _watchAudioIndex();
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSurah(),
      _loadBookmarks(),
      _loadVoice(),
    ]);
  }

  void _watchAudioIndex() {
    _indexSub = audioHandler.player.currentIndexStream.listen((index) {
      if (!mounted || index == null) return;
      setState(() {
        _currentPlayingAyah = index + 1;
      });
    });
  }

  Future<void> _loadVoice() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedVoice = prefs.getString('selectedVoice') ?? _selectedVoice;
    });
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('bookmarks');
    if (!mounted || value == null) return;
    setState(() {
      _bookmarks = List<Map<String, dynamic>>.from(jsonDecode(value));
    });
  }

  Future<void> _toggleBookmark(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarks.indexWhere(
      (b) =>
          b['surahNumber'] == widget.surahNumber &&
          b['ayahNumber'] == ayah.numberInSurah,
    );

    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add({
        'surahNumber': widget.surahNumber,
        'ayahNumber': ayah.numberInSurah,
        'surahName': widget.surahName,
        'englishName': widget.englishName,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks', jsonEncode(_bookmarks));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setLastRead(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadSurah', widget.surahNumber ?? 1);
    await prefs.setInt('lastReadAyah', ayah.numberInSurah);
    await prefs.setString('lastReadSurahName', widget.englishName);
  }

  Future<void> _loadSurah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isJuz = widget.juzNumber != null;
      final key = isJuz ? 'juz_reading_v2_' : 'surah_reading_v2_';

      String? cached;
      if (prefs.containsKey(key)) {
        cached = prefs.getString(key);
      }

      Map<String, dynamic> combinedData;
      if (cached != null) {
        combinedData = jsonDecode(cached);
      } else if (!isJuz) {
        final response = await http.get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,en.sahih',
          ),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to load Surah');
        }
        combinedData = jsonDecode(response.body);
      } else {
        final ar = await http.get(
          Uri.parse(
              'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/quran-uthmani'),
        );
        final en = await http.get(
          Uri.parse(
              'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/en.sahih'),
        );

        if (ar.statusCode != 200 || en.statusCode != 200) {
          throw Exception('Failed to load Juz');
        }

        combinedData = {
          'data': [jsonDecode(ar.body)['data'], jsonDecode(en.body)['data']],
        };
      }

      await prefs.setString(key, jsonEncode(combinedData));
      _parseAndSetData(combinedData, isJuz: isJuz);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _parseAndSetData(Map<String, dynamic> data, {required bool isJuz}) {
    final list = data['data'] as List;
    final arabicEdition =
        list.firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani');
    final tlEdition = list.firstWhere(
      (e) => e['edition']['identifier'] == 'en.sahih',
      orElse: () => null,
    );

    final ayahs = <ReadingAyah>[];
    for (int i = 0; i < arabicEdition['ayahs'].length; i++) {
      final arAyah = arabicEdition['ayahs'][i];
      final tlAyah = tlEdition != null ? tlEdition['ayahs'][i] : null;
      ayahs.add(
        ReadingAyah(
          numberInSurah: arAyah['numberInSurah'],
          arabicText: arAyah['text'],
          translationText: tlAyah?['text'],
          number: arAyah['number'],
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _surahData = ReadingSurah(
        number: isJuz ? widget.juzNumber! : arabicEdition['number'],
        name: isJuz ? 'Juz' : arabicEdition['name'],
        englishName: widget.englishName,
        ayahs: ayahs,
      );
      _isLoading = false;
    });
  }

  Widget _ayahCard(ReadingAyah ayah) {
    final textTheme = Theme.of(context).textTheme;
    final isBookmarked = _bookmarks.any(
      (b) =>
          b['surahNumber'] == widget.surahNumber &&
          b['ayahNumber'] == ayah.numberInSurah,
    );

    final isPlaying = _currentPlayingAyah == ayah.numberInSurah;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulseOpacity = 0.5 + (_pulseController.value * 0.5);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border(
              left: BorderSide(
                color: isPlaying
                    ? context.palette.goldPrimary
                        .withValues(alpha: pulseOpacity)
                    : AppColorValues.transparent,
                width: AppSizes.cardAccentWidth,
              ),
            ),
          ),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            backgroundColor: isPlaying
                ? context.palette.bgElevated
                : context.palette.bgSurface,
            child: InkWell(
              onTap: () {
                _setLastRead(ayah);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved as last read')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      GoldBadge(label: ayah.numberInSurah.toString()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArabicText(
                    ayah.arabicText,
                    fontSize: ArabicSize.ayah,
                  ),
                  if (_showTranslation && ayah.translationText != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const GoldDivider(opacity: 0.4),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ayah.translationText!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GoldIconButton(
                        icon: isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: AppSizes.iconButtonSmall,
                        isActive: isBookmarked,
                        onTap: () => _toggleBookmark(ayah),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GoldIconButton(
                        icon: Icons.share_rounded,
                        size: AppSizes.iconButtonSmall,
                        onTap: () {
                          final text = _showTranslation
                              ? '${ayah.arabicText}\n\n${ayah.translationText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}'
                              : '${ayah.arabicText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}';
                          SharePlus.instance.share(ShareParams(text: text));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _audioBar() {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: AppSizes.audioBarHeight,
      decoration: BoxDecoration(
        color: context.palette.bgElevated,
        border: Border(
          top: BorderSide(
            color: context.palette.goldMuted,
            width: AppSizes.dividerThickness,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _selectedVoice,
                style: textTheme.labelSmall?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: audioHandler.player.positionStream,
              builder: (context, posSnapshot) {
                final position = posSnapshot.data ?? Duration.zero;
                final duration = audioHandler.player.duration ?? Duration.zero;
                final max = duration.inMilliseconds <= 0
                    ? AppSpacing.xs
                    : duration.inMilliseconds.toDouble();
                final value = position.inMilliseconds > max
                    ? max
                    : position.inMilliseconds.toDouble();

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: context.palette.goldPrimary,
                        inactiveTrackColor: context.palette.bgSubtle,
                        thumbColor: context.palette.goldPrimary,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: AppSpacing.sm - AppSpacing.xs / 2,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        max: max,
                        onChanged: (newValue) {
                          audioHandler.player.seek(
                            Duration(milliseconds: newValue.round()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GoldIconButton(
                            icon: Icons.skip_previous_rounded,
                            onTap: () => audioHandler.skipToPrevious(),
                          ),
                          GoldIconButton(
                            icon: Icons.replay_10_rounded,
                            onTap: () {
                              final back =
                                  position - const Duration(seconds: 10);
                              audioHandler.player
                                  .seek(back.isNegative ? Duration.zero : back);
                            },
                          ),
                          _PlayButton(),
                          GoldIconButton(
                            icon: Icons.forward_10_rounded,
                            onTap: () {
                              audioHandler.player
                                  .seek(position + const Duration(seconds: 10));
                            },
                          ),
                          GoldIconButton(
                            icon: Icons.skip_next_rounded,
                            onTap: () => audioHandler.skipToNext(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxAppBar(
        title: Text(widget.englishName),
        subtitle: Text(widget.surahName),
        showBack: true,
        actions: [
          GoldIconButton(
            icon: _showTranslation
                ? Icons.translate_rounded
                : Icons.g_translate_rounded,
            isActive: _showTranslation,
            onTap: () => setState(() => _showTranslation = !_showTranslation),
          ),
          GoldIconButton(
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
          GoldIconButton(
            icon: Icons.share_rounded,
            onTap: () {
              if (_surahData == null) return;
              SharePlus.instance.share(
                ShareParams(
                    text: '${_surahData!.englishName} - ${widget.surahName}'),
              );
            },
          ),
        ],
      ),
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: AppCard(
                          glow: true,
                          child: Column(
                            children: [
                              const ArabicText(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                fontSize: ArabicSize.ayahLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const GoldDivider(),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: _surahData!.ayahs.length,
                          itemBuilder: (context, index) =>
                              _ayahCard(_surahData!.ayahs[index]),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: _audioBar(),
    );
  }
}

class _PlayButton extends StatefulWidget {
  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.playBreath,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: audioHandler.player.playingStream,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = playing ? (1 + (_controller.value * 0.05)) : 1.0;
            return Transform.scale(
              scale: scale,
              child: GoldIconButton(
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: AppSizes.playButton,
                onTap: () async {
                  if (playing) {
                    await audioHandler.pause();
                  } else {
                    await audioHandler.play();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
