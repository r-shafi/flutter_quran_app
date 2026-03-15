import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';

class ReadingSurah {
  final int number;
  final String name;
  final String englishName;
  final int? initialAyahNumber;
  final List<ReadingAyah> ayahs;

  ReadingSurah({
    required this.number,
    required this.name,
    required this.englishName,
    this.initialAyahNumber,
    required this.ayahs,
  });
}

class ReadingAyah {
  final int numberInSurah;
  final String arabicText;
  final String? translationText;
  final int number; // Global ayah number

  ReadingAyah({
    required this.numberInSurah,
    required this.arabicText,
    this.translationText,
    required this.number,
  });
}

class SurahReadingScreen extends StatefulWidget {
  final int? surahNumber;
  final int? juzNumber;
  final String surahName;
  final String englishName;
  final int? initialAyahNumber;

  const SurahReadingScreen({
    super.key,
    this.surahNumber,
    this.juzNumber,
    required this.surahName,
    required this.englishName,
    this.initialAyahNumber,
  });

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen> {
  bool _showTranslation = false;
  ReadingSurah? _surahData;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _bookmarks = [];
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getString('bookmarks');
    if (b != null) {
      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(jsonDecode(b));
      });
    }
  }

  Future<void> _toggleBookmark(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarks.indexWhere((b) =>
        b['surahNumber'] == widget.surahNumber &&
        b['ayahNumber'] == ayah.numberInSurah);

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
    setState(() {});
  }

  Future<void> _setLastRead(ReadingAyah ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadSurah', widget.surahNumber ?? 1);
    await prefs.setInt('lastReadAyah', ayah.numberInSurah);
    await prefs.setString('lastReadSurahName', widget.englishName);
  }

// _loadSurah replaces for Juz and Surah support
  Future<void> _loadSurah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isJuz = widget.juzNumber != null;
      final cacheKey = isJuz ? 'juz_reading_v2_' : 'surah_reading_v2_';

      String? cachedData;
      if (prefs.containsKey(cacheKey)) {
        cachedData = prefs.getString(cacheKey);
      }

      if (cachedData != null) {
        _parseAndSetData(jsonDecode(cachedData), isJuz: isJuz);
        return;
      }

      Map<String, dynamic> combinedData = {'data': []};

      if (!isJuz) {
        final response = await http.get(Uri.parse(
            'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,en.sahih'));
        if (response.statusCode == 200) {
          combinedData = jsonDecode(response.body);
        } else {
          throw Exception('Failed to load surah');
        }
      } else {
        final resAr = await http.get(Uri.parse(
            'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/quran-uthmani'));
        final resEn = await http.get(Uri.parse(
            'https://api.alquran.cloud/v1/juz/${widget.juzNumber}/en.sahih'));

        if (resAr.statusCode == 200 && resEn.statusCode == 200) {
          final arBody = jsonDecode(resAr.body)['data'];
          final enBody = jsonDecode(resEn.body)['data'];
          combinedData['data'] = [arBody, enBody];
        } else {
          throw Exception('Failed to load juz');
        }
      }

      prefs.setString(cacheKey, jsonEncode(combinedData));
      _parseAndSetData(combinedData, isJuz: isJuz);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _parseAndSetData(Map<String, dynamic> data, {bool isJuz = false}) {
    final list = data['data'] as List;
    final arabicEdition =
        list.firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani');
    final tlEdition = list.firstWhere(
        (e) => e['edition']['identifier'] == 'en.sahih',
        orElse: () => null);

    final ayahs = <ReadingAyah>[];
    // In juz, 'ayahs' array has surah info inside each ayah
    for (int i = 0; i < arabicEdition['ayahs'].length; i++) {
      final arAyah = arabicEdition['ayahs'][i];
      final tlAyah = tlEdition != null ? tlEdition['ayahs'][i] : null;

      ayahs.add(ReadingAyah(
        numberInSurah: arAyah['numberInSurah'],
        arabicText: arAyah['text'],
        translationText: tlAyah?['text'],
        number: arAyah['number'],
      ));
    }

    setState(() {
      _surahData = ReadingSurah(
        number: isJuz ? widget.juzNumber! : arabicEdition['number'],
        name: isJuz ? 'Juz ' : arabicEdition['name'],
        englishName: widget.englishName,
        ayahs: ayahs,
      );
      for (var a in ayahs) {
        _ayahKeys[a.numberInSurah] = GlobalKey();
      }
      _isLoading = false;
    });

    if (widget.initialAyahNumber != null &&
        widget.initialAyahNumber! <= ayahs.length) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final key = _ayahKeys[widget.initialAyahNumber!];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final arabicTextTheme = Theme.of(context).extension<ArabicTextTheme>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.englishName),
        actions: [
          IconButton(
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.g_translate,
              color: _showTranslation ? colorScheme.primary : null,
            ),
            tooltip: 'Toggle Translation',
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _surahData!.ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = _surahData!.ayahs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          _setLastRead(ayah);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved as last read'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    child: Text(
                                      ayah.numberInSurah.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      ayah.arabicText,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: (arabicTextTheme?.ayahStyle ??
                                              const TextStyle(fontSize: 24))
                                          .copyWith(
                                        height: 1.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_showTranslation &&
                                  ayah.translationText != null) ...[
                                const Divider(height: 32),
                                Text(
                                  ayah.translationText!,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _bookmarks.any((b) =>
                                              b['surahNumber'] ==
                                                  widget.surahNumber &&
                                              b['ayahNumber'] ==
                                                  ayah.numberInSurah)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleBookmark(ayah),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 20),
                                    onPressed: () {
                                      final textToShare = _showTranslation
                                          ? '${ayah.arabicText}\n\n${ayah.translationText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}'
                                          : '${ayah.arabicText}\n\n- Surah ${widget.englishName}, Ayah ${ayah.numberInSurah}';
                                      Share.share(textToShare);
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
                ),
    );
  }
}
