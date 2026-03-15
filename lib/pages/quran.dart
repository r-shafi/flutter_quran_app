import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/main.dart';
import 'package:quran_app/models/surah_content.dart';
import 'package:quran_app/models/surah_list.dart';
import 'package:quran_app/pages/surah_reading.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<SurahListModel> fetchSurahList() async {
  final prefs = await _prefs;
  final cache = prefs.getString('surahList');
  if (cache != null) {
    return SurahListModel.fromMap(jsonDecode(cache));
  }

  final response =
      await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load Surah list');
  }

  await prefs.setString('surahList', response.body);
  return SurahListModel.fromMap(jsonDecode(response.body));
}

Future<SurahContentModel> fetchSurahContent(int id) async {
  final voice = await _prefs.then((prefs) {
    return prefs.getString('selectedVoice') ?? 'ar.ahmedajamy';
  });

  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/surah/$id/$voice'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load Surah content');
  }

  return SurahContentModel.fromMap(jsonDecode(response.body));
}

class Quran extends StatefulWidget {
  const Quran({super.key});

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> with SingleTickerProviderStateMixin {
  late final Future<SurahListModel> _futureSurahList;
  final List<int> _favoriteSurahs = [];
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _listAnimationController;

  String _searchQuery = '';
  bool _isSearching = false;
  int _lastTrack = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _futureSurahList = fetchSurahList();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadFavorites();

    audioHandler.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        (prefs.getStringList('favoriteSurahs') ?? []).map(int.parse).toList();
    if (!mounted) return;
    setState(() {
      _favoriteSurahs.clear();
      _favoriteSurahs.addAll(list);
    });
  }

  Future<void> _toggleFavorite(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteSurahs.contains(surahNumber)) {
        _favoriteSurahs.remove(surahNumber);
      } else {
        _favoriteSurahs.add(surahNumber);
      }
    });

    await prefs.setStringList(
      'favoriteSurahs',
      _favoriteSurahs.map((e) => e.toString()).toList(),
    );
  }

  Future<void> audioPlaybackController(int surah, String surahName) async {
    if (audioHandler.player.playing && _lastTrack == surah) {
      await audioHandler.pause();
      return;
    }

    if (!audioHandler.player.playing && _lastTrack == surah) {
      await audioHandler.play();
      return;
    }

    if (audioHandler.player.playing && _lastTrack != surah) {
      await audioHandler.stop();
    }

    setState(() {
      _lastTrack = surah;
      _isPlaying = true;
    });

    final content = await fetchSurahContent(surah);
    final items = content.data.ayahs
        .map((ayah) => MediaItem(
              id: ayah.audio,
              album: surahName,
              title: 'Ayah ${ayah.numberInSurah}',
              extras: {
                'surahNumber': surah,
                'ayahNumber': ayah.numberInSurah,
              },
            ))
        .toList();

    await audioHandler.updateQueue(items);
    await audioHandler.player.setAudioSources(
        items.map((e) => AudioSource.uri(Uri.parse(e.id))).toList());
    await audioHandler.play();
  }

  Widget _searchTitle() {
    if (!_isSearching) {
      return const Text('Quran');
    }

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
          _listAnimationController
            ..reset()
            ..forward();
        });
      },
      cursorColor: context.palette.goldPrimary,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: 'Search Surahs...',
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: context.palette.textMuted),
        filled: true,
        fillColor: context.palette.bgElevated,
        prefixIcon:
            Icon(Icons.search_rounded, color: context.palette.goldMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildSurahCard(SurahMetaModel surah, int index) {
    final textTheme = Theme.of(context).textTheme;
    final isFavorite = _favoriteSurahs.contains(surah.number);
    final isSelected = _lastTrack == surah.number;

    final stagger =
        (index > 15 ? 15 : index) * AppDurations.listStaggerStep.inMilliseconds;
    final start = stagger / AppDurations.screenFade.inMilliseconds / 10;
    final intervalStart = start.clamp(0, 0.8).toDouble();
    final curve = CurvedAnimation(
      parent: _listAnimationController,
      curve: Interval(intervalStart, 1, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: Column(
          children: [
            PressableCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahReadingScreen(
                      surahNumber: surah.number,
                      surahName: surah.name,
                      englishName: surah.englishName,
                    ),
                  ),
                );
              },
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              backgroundColor: isSelected
                  ? context.palette.bgElevated
                  : context.palette.bgSurface,
              child: SizedBox(
                height: AppSpacing.xxl + AppSpacing.lg,
                child: Row(
                  children: [
                    GoldBadge(label: surah.number.toString()),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.englishName,
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            surah.name,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: ArabicSize.surahName,
                              color: context.palette.goldPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${surah.numberOfAyahs} Ayahs',
                          style: textTheme.labelSmall?.copyWith(
                            color: context.palette.textMuted,
                          ),
                        ),
                        Text(
                          'Juz ${((surah.number - 1) ~/ AppSpacing.xs) + 1}',
                          style: textTheme.labelSmall?.copyWith(
                            color: context.palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GoldIconButton(
                      icon: isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      onTap: () => _toggleFavorite(surah.number),
                      isActive: isFavorite,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    GoldIconButton(
                      icon: isSelected && _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onTap: () => audioPlaybackController(
                          surah.number, surah.englishName),
                    ),
                  ],
                ),
              ),
            ),
            const GoldDivider(opacity: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _surahTabView(List<SurahMetaModel> all,
      {required bool favoritesOnly}) {
    var list = all;

    if (favoritesOnly) {
      list = all.where((e) => _favoriteSurahs.contains(e.number)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((e) =>
              e.englishName.toLowerCase().contains(_searchQuery) ||
              e.name.contains(_searchQuery))
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildSurahCard(list[index], index),
    );
  }

  Widget _juzTabView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: AppSpacing.xl.toInt() - AppSpacing.sm.toInt(),
      itemBuilder: (context, index) {
        final juz = index + 1;
        return PressableCard(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahReadingScreen(
                  juzNumber: juz,
                  surahName: 'Juz $juz',
                  englishName: 'Juz $juz',
                ),
              ),
            );
          },
          child: Row(
            children: [
              GoldBadge(label: '$juz', compact: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Juz $juz',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: context.palette.goldMuted),
            ],
          ),
        );
      },
    );
  }

  Widget _audioBar() {
    if (!_isPlaying && _lastTrack == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.palette.bgSurface,
        border: Border(
          top: BorderSide(
              color: context.palette.goldMuted,
              width: AppSizes.dividerThickness),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GoldIconButton(
            icon: Icons.skip_previous_rounded,
            onTap: _lastTrack > 1
                ? () => audioPlaybackController(
                    _lastTrack - 1, 'Surah ${_lastTrack - 1}')
                : null,
          ),
          GoldIconButton(
            icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: () async {
              if (_isPlaying) {
                await audioHandler.pause();
              } else {
                await audioHandler.play();
              }
            },
          ),
          GoldIconButton(
            icon: Icons.stop_rounded,
            onTap: () async {
              await audioHandler.stop();
              if (!mounted) return;
              setState(() {
                _isPlaying = false;
                _lastTrack = 0;
              });
            },
          ),
          GoldIconButton(
            icon: Icons.skip_next_rounded,
            onTap: _lastTrack < 114
                ? () => audioPlaybackController(
                    _lastTrack + 1, 'Surah ${_lastTrack + 1}')
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: GoldIconButton(
              icon: Icons.chevron_left,
              onTap: () => Navigator.maybePop(context),
            ),
          ),
          title: _searchTitle(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GoldIconButton(
                icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: context.palette.goldPrimary,
            indicatorWeight: AppSizes.tabIndicatorThickness,
            labelStyle: textTheme.labelLarge,
            labelColor: context.palette.goldPrimary,
            unselectedLabelColor: context.palette.textMuted,
            tabs: const [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: ScreenBackground(
          child: FutureBuilder<SurahListModel>(
            future: _futureSurahList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data;
              return TabBarView(
                children: [
                  _surahTabView(data, favoritesOnly: false),
                  _juzTabView(),
                  _surahTabView(data, favoritesOnly: true),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _audioBar(),
      ),
    );
  }
}
