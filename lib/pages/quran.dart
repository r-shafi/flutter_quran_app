import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_app/pages/surah_reading.dart';
import 'package:quran_app/main.dart'; // audioHandler
import 'package:audio_service/audio_service.dart';

import './../models/surah_content.dart';
import './../models/surah_list.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<SurahListModel> fetchSurahList() async {
  final SharedPreferences prefs = await _prefs;
  final String? surahList = prefs.getString('surahList');

  if (surahList != null) {
    return SurahListModel.fromMap(jsonDecode(surahList));
  }

  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/surah'),
  );

  if (response.statusCode == 200) {
    prefs.setString('surahList', response.body);
    return SurahListModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

Future<SurahContentModel> fetchSurahContent(int id) async {
  String voice = await _prefs.then((SharedPreferences prefs) {
    return prefs.getString('selectedVoice') ?? 'ar.ahmedajamy';
  });

  final response = await http.get(
    Uri.parse('https://api.alquran.cloud/v1/surah/$id/$voice'),
  );

  if (response.statusCode == 200) {
    return SurahContentModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load data!');
  }
}

class Quran extends StatefulWidget {
  const Quran({super.key});

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> {
  late Future<SurahListModel> _futureSurahList;
  List<int> _favoriteSurahs = [];
  String _searchQuery = '';
  bool _filterFavorites = false;

  int lastTrack = 0;
  bool isPlaying = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureSurahList = fetchSurahList();
    _loadFavorites();

    audioHandler.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteSurahs =
          (prefs.getStringList('favoriteSurahs') ?? []).map(int.parse).toList();
    });
  }

  Future<void> _toggleFavorite(int num) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteSurahs.contains(num)) {
        _favoriteSurahs.remove(num);
      } else {
        _favoriteSurahs.add(num);
      }
    });
    await prefs.setStringList(
        'favoriteSurahs', _favoriteSurahs.map((e) => e.toString()).toList());
  }

  Future<void> audioPlaybackController(int surah, String surahName) async {
    if (audioHandler.player.playing && lastTrack == surah) {
      await audioHandler.pause();
      return;
    }

    if (!audioHandler.player.playing && lastTrack == surah) {
      await audioHandler.play();
      return;
    }

    if (audioHandler.player.playing && lastTrack != surah) {
      await audioHandler.stop();
    }

    setState(() {
      lastTrack = surah;
      isPlaying = true;
    });

    final content = await fetchSurahContent(surah);

    final items = content.data.ayahs
        .map((ayah) => MediaItem(
              id: ayah.audio,
              album: surahName,
              title: 'Ayah ${ayah.numberInSurah}',
            ))
        .toList();

    await audioHandler.updateQueue(items);

    final playlist = ConcatenatingAudioSource(
      children: items.map((i) => AudioSource.uri(Uri.parse(i.id))).toList(),
    );

    await audioHandler.player.setAudioSource(playlist);
    await audioHandler.play();
  }

  Widget _buildSurahList(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final arabicTextTheme = theme.extension<ArabicTextTheme>();

    return FutureBuilder(
      future: _futureSurahList,
      builder: (context, AsyncSnapshot<SurahListModel> snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        }

        var list = snapshot.data!.data;

        if (_filterFavorites) {
          list = list.where((s) => _favoriteSurahs.contains(s.number)).toList();
        }

        if (_searchQuery.isNotEmpty) {
          list = list
              .where((s) =>
                  s.englishName.toLowerCase().contains(_searchQuery) ||
                  s.name.contains(_searchQuery))
              .toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final surah = list[i];
            final isSelected = lastTrack == surah.number;
            final isFav = _favoriteSurahs.contains(surah.number);

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahReadingScreen(
                        surahNumber: surah.number,
                        surahName: surah.name,
                        englishName: surah.englishName,
                      ),
                    ),
                  );
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                tileColor: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerLow,
                leading: IconButton(
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _toggleFavorite(surah.number),
                ),
                title: Text(
                  surah.englishName,
                  style: textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  surah.name,
                  style: (arabicTextTheme?.ayahStyle ??
                          textTheme.titleMedium ??
                          const TextStyle())
                      .copyWith(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    audioPlaybackController(surah.number, surah.englishName);
                  },
                  icon: Icon(
                    isSelected && isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJuzList(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 30,
      itemBuilder: (context, i) {
        final juz = i + 1;
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahReadingScreen(
                    juzNumber: juz,
                    surahName: 'Juz $juz',
                    englishName: 'Juz $juz',
                  ),
                ),
              );
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            tileColor: colorScheme.surfaceContainerLow,
            title: Text(
              'Juz $juz',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quran'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Surahs'),
              Tab(text: 'Juz'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_filterFavorites ? Icons.star : Icons.star_border),
              tooltip: 'Filter Favorites',
              onPressed: () {
                setState(() {
                  _filterFavorites = !_filterFavorites;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Search Surah',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSurahList(t),
                  _buildJuzList(t),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: isPlaying || lastTrack != 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (lastTrack > 1) {
                          audioPlaybackController(
                              lastTrack - 1, 'Surah ${lastTrack - 1}');
                        }
                      },
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await audioHandler.pause();
                        } else {
                          await audioHandler.play();
                        }
                      },
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () async {
                        await audioHandler.stop();
                        setState(() {
                          isPlaying = false;
                          lastTrack = 0;
                        });
                      },
                      icon: const Icon(Icons.stop),
                    ),
                    IconButton(
                      onPressed: () {
                        if (lastTrack < 114) {
                          audioPlaybackController(
                              lastTrack + 1, 'Surah ${lastTrack + 1}');
                        }
                      },
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
