import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<dynamic> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final res =
          await http.get(Uri.parse('https://api.hadith.gading.dev/books'));
      if (res.statusCode == 200) {
        final payload = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _books = payload['data'];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(title: Text('Hadith'), showBack: true),
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const SectionHeader(title: 'Hadith Collections'),
                  const SizedBox(height: AppSpacing.md),
                  ..._books.map((book) {
                    return PressableCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HadithListScreen(
                              bookId: book['id'],
                              bookName: book['name'],
                              totalHadith: book['available'],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book['name'],
                                    style: textTheme.titleMedium),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${book['available']} Hadith',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: context.palette.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: context.palette.goldMuted),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.totalHadith,
  });

  final String bookId;
  final String bookName;
  final int totalHadith;

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final List<dynamic> _hadiths = [];
  bool _isLoading = false;
  int _rangeStart = 1;
  int _rangeEnd = 20;
  List<Map<String, dynamic>> _bookmarkedHadiths = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _fetchHadiths();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('bookmarks_hadith');
    if (!mounted || value == null) return;
    setState(() {
      _bookmarkedHadiths = List<Map<String, dynamic>>.from(jsonDecode(value));
    });
  }

  Future<void> _toggleBookmark(dynamic hadith) async {
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarkedHadiths.indexWhere(
      (b) => b['bookId'] == widget.bookId && b['number'] == hadith['number'],
    );

    if (index >= 0) {
      _bookmarkedHadiths.removeAt(index);
    } else {
      _bookmarkedHadiths.add({
        'bookId': widget.bookId,
        'bookName': widget.bookName,
        'number': hadith['number'],
        'arab': hadith['arab'],
        'translation': hadith['id'],
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks_hadith', jsonEncode(_bookmarkedHadiths));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchHadiths() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final end =
          _rangeEnd > widget.totalHadith ? widget.totalHadith : _rangeEnd;
      final url =
          'https://api.hadith.gading.dev/books/${widget.bookId}?range=$_rangeStart-$end';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final payload = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _hadiths.addAll(payload['data']['hadiths']);
          _rangeStart += 20;
          _rangeEnd += 20;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: LuxAppBar(title: Text(widget.bookName), showBack: true),
      body: ScreenBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _hadiths.length + 1,
          itemBuilder: (context, index) {
            if (index == _hadiths.length) {
              return AppCard(
                child: TextButton(
                  onPressed: _rangeStart > widget.totalHadith || _isLoading
                      ? null
                      : _fetchHadiths,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Load More',
                          style: textTheme.labelLarge?.copyWith(
                            color: context.palette.goldPrimary,
                          ),
                        ),
                ),
              );
            }

            final hadith = _hadiths[index];
            final isBookmarked = _bookmarkedHadiths.any(
              (b) =>
                  b['bookId'] == widget.bookId &&
                  b['number'] == hadith['number'],
            );

            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      GoldBadge(label: hadith['number'].toString()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArabicText(
                    hadith['arab'] ?? '',
                    fontSize: ArabicSize.hadith,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const GoldDivider(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hadith['id'] ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Narrator chain',
                    style: textTheme.labelSmall?.copyWith(
                      color: context.palette.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GoldIconButton(
                        icon: isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        onTap: () => _toggleBookmark(hadith),
                        isActive: isBookmarked,
                      ),
                    ],
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
