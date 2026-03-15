import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _HadithCategory {
  const _HadithCategory({
    required this.id,
    required this.title,
    required this.hadiths,
  });

  final int id;
  final String title;
  final List<Map<String, dynamic>> hadiths;

  int get total => hadiths.length;
}

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  static const Map<String, String> _englishEditionByBookId = {
    'abu-daud': 'eng-abudawud',
    'ahmad': 'eng-ahmad',
    'bukhari': 'eng-bukhari',
    'darimi': 'eng-darimi',
    'ibnu-majah': 'eng-ibnmajah',
    'malik': 'eng-malik',
    'muslim': 'eng-muslim',
    'nasai': 'eng-nasai',
    'tirmidzi': 'eng-tirmidhi',
  };

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
          _books = List<dynamic>.from(payload['data'])
              .where(
                (book) => _englishEditionByBookId.containsKey(book['id']),
              )
              .toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // Fall back to a local list when upstream metadata is unavailable.
    }

    if (!mounted) return;
    setState(() {
      _books = [
        {'name': 'HR. Bukhari', 'id': 'bukhari', 'available': 0},
        {'name': 'HR. Muslim', 'id': 'muslim', 'available': 0},
        {'name': 'HR. Abu Daud', 'id': 'abu-daud', 'available': 0},
        {'name': 'HR. Tirmidzi', 'id': 'tirmidzi', 'available': 0},
        {'name': 'HR. Nasai', 'id': 'nasai', 'available': 0},
        {'name': 'HR. Ibnu Majah', 'id': 'ibnu-majah', 'available': 0},
        {'name': 'HR. Malik', 'id': 'malik', 'available': 0},
        {'name': 'HR. Ahmad', 'id': 'ahmad', 'available': 0},
        {'name': 'HR. Darimi', 'id': 'darimi', 'available': 0},
      ];
      _isLoading = false;
    });
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
                  const SectionHeader(title: 'Hadith Collections (English)'),
                  const SizedBox(height: AppSpacing.md),
                  ..._books.map((book) {
                    return PressableCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      onTap: () {
                        final englishEditionId =
                            _englishEditionByBookId[book['id'] as String];
                        if (englishEditionId == null) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HadithCategoryScreen(
                              bookId: book['id'] as String,
                              bookName: book['name'] as String,
                              englishEditionId: englishEditionId,
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
                                Text(book['name'] as String,
                                    style: textTheme.titleMedium),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'English text with section categories',
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

class HadithCategoryScreen extends StatefulWidget {
  const HadithCategoryScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.englishEditionId,
  });

  final String bookId;
  final String bookName;
  final String englishEditionId;

  @override
  State<HadithCategoryScreen> createState() => _HadithCategoryScreenState();
}

class _HadithCategoryScreenState extends State<HadithCategoryScreen> {
  List<_HadithCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _normalizeSectionTitle(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();

    if (value is Map) {
      final map = Map<String, dynamic>.from(value as Map);
      final name = (map['title'] ?? map['name'] ?? map['section'] ?? '')
          .toString()
          .trim();
      if (name.isNotEmpty) return name;

      final first = _asInt(
        map['hadithnumber_first'] ??
            map['hadith_first'] ??
            map['first'] ??
            map['start'],
      );
      final last = _asInt(
        map['hadithnumber_last'] ??
            map['hadith_last'] ??
            map['last'] ??
            map['end'],
      );

      if (first > 0 && last >= first) {
        return 'Hadith $first-$last';
      }
      if (last > 0) {
        return 'Up to Hadith $last';
      }
    }

    return '';
  }

  Future<void> _fetchCategories() async {
    final url =
        'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/${widget.englishEditionId}.json';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception('Unable to load hadith categories.');
      }

      final payload = jsonDecode(res.body) as Map<String, dynamic>;
      final hadithsRaw = List<dynamic>.from(payload['hadiths'] ?? []);
      final metadata = payload['metadata'] is Map<String, dynamic>
          ? payload['metadata'] as Map<String, dynamic>
          : <String, dynamic>{};

      final sectionTitles = <int, String>{};

      void addSectionTitles(dynamic sectionMapRaw) {
        if (sectionMapRaw is! Map) return;
        sectionMapRaw.forEach((key, value) {
          final id = _asInt(key);
          final title = _normalizeSectionTitle(value);
          if (title.isNotEmpty) {
            sectionTitles[id] = title;
          }
        });
      }

      addSectionTitles(metadata['sections']);
      addSectionTitles(
          metadata['section_details'] ?? metadata['sectionDetails']);

      final grouped = <int, List<Map<String, dynamic>>>{};
      for (final raw in hadithsRaw) {
        if (raw is! Map) continue;

        final hadith = Map<String, dynamic>.from(raw as Map);
        final reference = hadith['reference'] is Map
            ? Map<String, dynamic>.from(hadith['reference'] as Map)
            : <String, dynamic>{};
        final sectionId = _asInt(reference['book']);

        grouped
            .putIfAbsent(sectionId, () => <Map<String, dynamic>>[])
            .add(hadith);
      }

      final sortedSectionIds = grouped.keys.toList()..sort();
      final categories = sortedSectionIds.map((sectionId) {
        final sectionTitle = sectionTitles[sectionId];
        final label = sectionTitle == null || sectionTitle.trim().isEmpty
            ? (sectionId == 0 ? 'Uncategorized' : 'Section $sectionId')
            : 'Section $sectionId - $sectionTitle';

        return _HadithCategory(
          id: sectionId,
          title: label,
          hadiths: grouped[sectionId]!,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: LuxAppBar(title: Text(widget.bookName), showBack: true),
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      const SectionHeader(title: 'Categories'),
                      const SizedBox(height: AppSpacing.md),
                      ..._categories.map(
                        (category) => PressableCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HadithListScreen(
                                  bookId: widget.bookId,
                                  bookName: widget.bookName,
                                  categoryLabel: category.title,
                                  categoryHadiths: category.hadiths,
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
                                    Text(category.title,
                                        style: textTheme.titleMedium),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${category.total} Hadith',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: context.palette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.palette.goldMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
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
    this.totalHadith,
    this.categoryStart,
    this.categoryEnd,
    this.categoryLabel,
    this.categoryHadiths,
  });

  final String bookId;
  final String bookName;
  final int? totalHadith;
  final int? categoryStart;
  final int? categoryEnd;
  final String? categoryLabel;
  final List<Map<String, dynamic>>? categoryHadiths;

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  static const int _pageSize = 20;

  final List<Map<String, dynamic>> _hadiths = [];
  final Map<int, String> _arabicByNumber = {};
  final Set<int> _loadingArabicNumbers = {};

  bool _isLoading = true;
  bool _isLoadingMore = false;
  late int _nextStart;
  List<Map<String, dynamic>> _bookmarkedHadiths = [];

  int get _resolvedCategoryStart => widget.categoryStart ?? 1;

  int get _resolvedCategoryEnd {
    if (widget.categoryEnd != null) {
      return widget.categoryEnd!;
    }
    if (widget.totalHadith != null && widget.totalHadith! > 0) {
      return widget.totalHadith!;
    }
    return _resolvedCategoryStart;
  }

  String get _resolvedCategoryLabel {
    if (widget.categoryLabel != null &&
        widget.categoryLabel!.trim().isNotEmpty) {
      return widget.categoryLabel!;
    }
    return 'All Hadith';
  }

  bool get _usesLegacyPagination => widget.categoryHadiths == null;

  int _readHadithNumber(Map<String, dynamic> hadith) {
    final value = hadith['hadithnumber'] ?? hadith['number'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _readEnglishText(Map<String, dynamic> hadith) {
    return (hadith['text'] ?? hadith['id'] ?? '').toString();
  }

  @override
  void initState() {
    super.initState();
    _nextStart = _resolvedCategoryStart;
    _loadBookmarks();
    _initHadiths();
  }

  Future<void> _initHadiths() async {
    if (!_usesLegacyPagination) {
      setState(() {
        _hadiths
          ..clear()
          ..addAll(widget.categoryHadiths!);
        _isLoading = false;
      });
      return;
    }

    await _fetchHadithsLegacy(isInitial: true);
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('bookmarks_hadith');
    if (!mounted || value == null) return;
    setState(() {
      _bookmarkedHadiths = List<Map<String, dynamic>>.from(jsonDecode(value));
    });
  }

  Future<void> _toggleBookmark(Map<String, dynamic> hadith) async {
    final number = _readHadithNumber(hadith);
    final prefs = await SharedPreferences.getInstance();
    final index = _bookmarkedHadiths.indexWhere(
      (b) => b['bookId'] == widget.bookId && b['number'] == number,
    );

    if (index >= 0) {
      _bookmarkedHadiths.removeAt(index);
    } else {
      _bookmarkedHadiths.add({
        'bookId': widget.bookId,
        'bookName': widget.bookName,
        'number': number,
        'arab': _arabicByNumber[number] ?? '',
        'translation': _readEnglishText(hadith),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString('bookmarks_hadith', jsonEncode(_bookmarkedHadiths));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchHadithsLegacy({required bool isInitial}) async {
    if (_isLoadingMore || _nextStart > _resolvedCategoryEnd) return;

    setState(() {
      if (isInitial) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final end = _nextStart + _pageSize - 1 > _resolvedCategoryEnd
          ? _resolvedCategoryEnd
          : _nextStart + _pageSize - 1;
      final url =
          'https://api.hadith.gading.dev/books/${widget.bookId}?range=$_nextStart-$end';
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final payload = jsonDecode(res.body);
        final hadiths = List<dynamic>.from(payload['data']['hadiths'] ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        if (!mounted) return;
        setState(() {
          _hadiths.addAll(hadiths);
          _nextStart = end + 1;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadArabicForHadith(int hadithNumber) async {
    if (hadithNumber <= 0 ||
        _arabicByNumber.containsKey(hadithNumber) ||
        _loadingArabicNumbers.contains(hadithNumber)) {
      return;
    }

    setState(() => _loadingArabicNumbers.add(hadithNumber));

    try {
      final url =
          'https://api.hadith.gading.dev/books/${widget.bookId}?range=$hadithNumber-$hadithNumber';
      final res = await http.get(Uri.parse(url));

      String arabicText = '';
      if (res.statusCode == 200) {
        final payload = jsonDecode(res.body);
        final hadiths = List<dynamic>.from(payload['data']['hadiths'] ?? []);
        if (hadiths.isNotEmpty) {
          final first = Map<String, dynamic>.from(hadiths.first as Map);
          arabicText = (first['arab'] ?? '').toString();
        }
      }

      if (!mounted) return;
      setState(() {
        _arabicByNumber[hadithNumber] = arabicText;
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingArabicNumbers.remove(hadithNumber));
    }
  }

  Widget _buildLoadMoreCard(TextTheme textTheme) {
    final completedCategory = _nextStart > _resolvedCategoryEnd;

    return AppCard(
      child: TextButton(
        onPressed: completedCategory || _isLoadingMore
            ? null
            : () => _fetchHadithsLegacy(isInitial: false),
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : Text(
                completedCategory ? 'End of category' : 'Load More',
                style: textTheme.labelLarge?.copyWith(
                  color: completedCategory
                      ? context.palette.textMuted
                      : context.palette.goldPrimary,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loadedCount = _hadiths.length;
    final categoryTotal = _usesLegacyPagination
        ? (_resolvedCategoryEnd - _resolvedCategoryStart) + 1
        : loadedCount;

    return Scaffold(
      appBar: LuxAppBar(title: Text(widget.bookName), showBack: true),
      body: ScreenBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _resolvedCategoryLabel,
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '$loadedCount of $categoryTotal hadith loaded',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: context.palette.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.menu_book_rounded,
                              color: context.palette.goldMuted),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount:
                          _hadiths.length + (_usesLegacyPagination ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_usesLegacyPagination && index == _hadiths.length) {
                          return _buildLoadMoreCard(textTheme);
                        }

                        final hadith = _hadiths[index];
                        final number = _readHadithNumber(hadith);
                        final englishText = _readEnglishText(hadith);

                        final isBookmarked = _bookmarkedHadiths.any(
                          (b) =>
                              b['bookId'] == widget.bookId &&
                              b['number'] == number,
                        );

                        final isArabicLoading =
                            _loadingArabicNumbers.contains(number);
                        final arabicText = _arabicByNumber[number] ?? '';

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  GoldBadge(label: number.toString()),
                                  const Spacer(),
                                  GoldIconButton(
                                    icon: isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    onTap: () => _toggleBookmark(hadith),
                                    isActive: isBookmarked,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                englishText,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: context.palette.textPrimary,
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'English Translation',
                                style: textTheme.labelSmall?.copyWith(
                                  color: context.palette.textMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                decoration: BoxDecoration(
                                  color: context.palette.bgSubtle,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    childrenPadding: const EdgeInsets.fromLTRB(
                                      AppSpacing.md,
                                      0,
                                      AppSpacing.md,
                                      AppSpacing.md,
                                    ),
                                    onExpansionChanged: (expanded) {
                                      if (expanded) {
                                        _loadArabicForHadith(number);
                                      }
                                    },
                                    iconColor: context.palette.goldPrimary,
                                    collapsedIconColor:
                                        context.palette.goldMuted,
                                    title: Text(
                                      'Show Arabic Text',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: context.palette.textSecondary,
                                      ),
                                    ),
                                    children: [
                                      if (isArabicLoading)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: AppSpacing.sm,
                                          ),
                                          child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      else if (arabicText.trim().isNotEmpty)
                                        ArabicText(
                                          arabicText,
                                          fontSize: ArabicSize.subtitle,
                                          color: context.palette.textSecondary,
                                        )
                                      else
                                        Text(
                                          'Arabic text unavailable for this hadith.',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: context.palette.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
