import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/surah_reading.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _quranBookmarks = [];
  List<Map<String, dynamic>> _hadithBookmarks = [];
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    final quran = prefs.getString('bookmarks');
    final hadith = prefs.getString('bookmarks_hadith');

    final quranList = quran == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(quran));
    final hadithList = hadith == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(jsonDecode(hadith));

    quranList.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    hadithList.sort((a, b) =>
        (b['timestamp'] as String).compareTo(a['timestamp'] as String));

    if (!mounted) return;
    setState(() {
      _quranBookmarks = quranList;
      _hadithBookmarks = hadithList;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarks', jsonEncode(_quranBookmarks));
    await prefs.setString('bookmarks_hadith', jsonEncode(_hadithBookmarks));
  }

  void _deleteWithUndo(int index) {
    final isQuran = _selectedSegment == 0;
    final removed = isQuran ? _quranBookmarks[index] : _hadithBookmarks[index];

    setState(() {
      if (isQuran) {
        _quranBookmarks.removeAt(index);
      } else {
        _hadithBookmarks.removeAt(index);
      }
    });

    _persist();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bookmark deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              if (isQuran) {
                _quranBookmarks.insert(index, removed);
              } else {
                _hadithBookmarks.insert(index, removed);
              }
            });
            _persist();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeList =
        _selectedSegment == 0 ? _quranBookmarks : _hadithBookmarks;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Bookmarks'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.palette.bgElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    _segment('Quran', 0),
                    _segment('Hadith', 1),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: activeList.isEmpty
                    ? Center(
                        child: Text(
                          'No bookmarks found',
                          style: textTheme.bodyMedium?.copyWith(
                            color: context.palette.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: activeList.length,
                        itemBuilder: (context, index) {
                          final item = activeList[index];
                          return PressableCard(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            onTap: _selectedSegment == 0
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SurahReadingScreen(
                                          surahNumber: item['surahNumber'],
                                          surahName: item['surahName'] ?? '',
                                          englishName: item['englishName'],
                                          initialAyahNumber: item['ayahNumber'],
                                        ),
                                      ),
                                    ).then((_) => _loadBookmarks());
                                  }
                                : null,
                            child: InkWell(
                              onLongPress: () => _deleteWithUndo(index),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedSegment == 0
                                        ? '${item['englishName']} - Ayah ${item['ayahNumber']}'
                                        : '${item['bookName']} - Hadith ${item['number']}',
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _selectedSegment == 0
                                        ? item['surahName'] ?? ''
                                        : 'Saved Hadith bookmark',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: context.palette.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      item['timestamp']
                                              ?.toString()
                                              .split('T')
                                              .first ??
                                          '',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: context.palette.textMuted,
                                      ),
                                    ),
                                  ),
                                  const GoldDivider(opacity: 0.3),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segment(String label, int index) {
    final selected = _selectedSegment == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSegment = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: selected
                ? Border(
                    bottom: BorderSide(
                      color: context.palette.goldPrimary,
                      width: AppSizes.tabIndicatorThickness,
                    ),
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? context.palette.goldPrimary
                      : context.palette.textMuted,
                ),
          ),
        ),
      ),
    );
  }
}
