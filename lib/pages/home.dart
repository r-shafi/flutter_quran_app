import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/azkar.dart';
import 'package:quran_app/pages/bookmarks.dart';
import 'package:quran_app/pages/hadith.dart';
import 'package:quran_app/pages/prayer_times.dart';
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/widgets/drawer.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/arabic_text.dart';
import 'package:quran_app/presentation/widgets/geometric_pattern_painter.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_button.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.isDarkMode,
    required this.arabicFontSize,
    required this.notificationsEnabled,
    required this.onThemeModeChanged,
    required this.onArabicFontSizeChanged,
    required this.onNotificationsChanged,
  });

  final bool isDarkMode;
  final double arabicFontSize;
  final bool notificationsEnabled;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<double> onArabicFontSizeChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final AnimationController _heroRotation;
  Map<String, dynamic>? _ayahData;
  bool _isLoadingAyah = true;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _heroRotation = AnimationController(
      vsync: this,
      duration: AppDurations.heroPatternRotation,
    )..repeat();
    _fetchAyahOfTheDay();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _heroRotation.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('bookmarks');
    if (!mounted) return;
    setState(() {
      _bookmarks = value == null
          ? []
          : List<Map<String, dynamic>>.from(jsonDecode(value));
    });
  }

  Future<void> _fetchAyahOfTheDay() async {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year)).inDays + 1;
      final ayahIndex = (dayOfYear % 6236) + 1;
      final response = await http.get(
        Uri.parse(
          'https://api.alquran.cloud/v1/ayah/$ayahIndex/editions/quran-uthmani,en.sahih',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        if (!mounted) return;
        setState(() {
          _ayahData = {
            'arabic': data[0]['text'],
            'translation': data[1]['text'],
            'surah': data[0]['surah']['englishName'],
            'numberInSurah': data[0]['numberInSurah'],
          };
          _isLoadingAyah = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingAyah = false;
      });
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final latestBookmark = _bookmarks.isNotEmpty ? _bookmarks.last : null;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? AppSpacing.sm : AppSpacing.md;
    final heroHeight = screenWidth < 380 ? 190.0 : AppSizes.heroHeight;
    final basmalahSize =
        screenWidth < 380 ? ArabicSize.minimum - 2 : ArabicSize.minimum;

    return Scaffold(
      drawer: SettingsDrawer(
        isDarkMode: widget.isDarkMode,
        arabicFontSize: widget.arabicFontSize,
        notificationsEnabled: widget.notificationsEnabled,
        onThemeModeChanged: widget.onThemeModeChanged,
        onArabicFontSizeChanged: widget.onArabicFontSizeChanged,
        onNotificationsChanged: widget.onNotificationsChanged,
      ),
      appBar: const LuxAppBar(
        title: Text('Quran App'),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.md,
          ),
          children: [
            AnimatedBuilder(
              animation: _heroRotation,
              builder: (context, child) {
                return SizedBox(
                  height: heroHeight,
                  child: AppCard(
                    glow: true,
                    padding: EdgeInsets.zero,
                    backgroundColor: context.palette.bgElevated,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                context.palette.goldGlow,
                                AppColorValues.transparent,
                              ],
                            ),
                          ),
                        ),
                        GeometricPatternLayer(
                          opacity: 0.1,
                          rotationTurns: _heroRotation.value,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: basmalahSize,
                                  height: 2,
                                  color: context.palette.goldPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} · Hijri',
                                style: textTheme.labelSmall?.copyWith(
                                  color: context.palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Prayer Times'),
            const SizedBox(height: AppSpacing.md),
            _PrayerTimesStrip(
              onOpenPrayerScreen: () =>
                  _open(context, const PrayerTimesScreen()),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Ayah of the Day'),
                  const SizedBox(height: AppSpacing.md),
                  if (_isLoadingAyah)
                    const Center(child: CircularProgressIndicator())
                  else if (_ayahData == null)
                    Text(
                      'Could not load Ayah of the Day',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    )
                  else ...[
                    ArabicText(
                      _ayahData!['arabic'] as String,
                      fontSize: ArabicSize.ayahLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const GoldDivider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _ayahData!['translation'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '- ${_ayahData!['surah']} ${_ayahData!['numberInSurah']}',
                        style: textTheme.labelSmall?.copyWith(
                          color: context.palette.goldMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlineGoldButton(
                      label: 'Read Full Surah',
                      onPressed: () => _open(context, const Quran()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Quick Access'),
            const SizedBox(height: AppSpacing.md),
            _QuickAccessGrid(
              tiles: [
                _QuickTileData(
                  label: 'Quran',
                  icon: Icons.menu_book_rounded,
                  onTap: () => _open(context, const Quran()),
                ),
                _QuickTileData(
                  label: 'Hadith',
                  icon: Icons.history_edu_rounded,
                  onTap: () => _open(context, const HadithScreen()),
                ),
                _QuickTileData(
                  label: 'Azkar',
                  icon: Icons.volunteer_activism_rounded,
                  onTap: () => _open(context, const AzkarScreen()),
                ),
                _QuickTileData(
                  label: 'Prayer Times',
                  icon: Icons.schedule_rounded,
                  onTap: () => _open(context, const PrayerTimesScreen()),
                ),
              ],
            ),
            if (latestBookmark != null) ...[
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Continue Reading'),
              const SizedBox(height: AppSpacing.md),
              PressableCard(
                onTap: () => _open(context, const BookmarksScreen()),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestBookmark['englishName'] as String,
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Resume from Ayah ${latestBookmark['ayahNumber']}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.menu_book,
                      color: context.palette.goldPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = AppSizes.quickTile,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      child: PressableCard(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: AppSpacing.xxl - AppSpacing.sm,
                color: context.palette.goldPrimary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTileData {
  const _QuickTileData({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.tiles});

  final List<_QuickTileData> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;
        final tileHeight = isCompact ? 132.0 : AppSizes.quickTile;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return _QuickTile(
              label: tile.label,
              icon: tile.icon,
              onTap: tile.onTap,
              height: tileHeight,
            );
          },
        );
      },
    );
  }
}

class _PrayerTimesStrip extends StatefulWidget {
  const _PrayerTimesStrip({required this.onOpenPrayerScreen});

  final VoidCallback onOpenPrayerScreen;

  @override
  State<_PrayerTimesStrip> createState() => _PrayerTimesStripState();
}

class _PrayerTimesStripState extends State<_PrayerTimesStrip> {
  static const _data = [
    {'name': 'Fajr', 'time': '05:00'},
    {'name': 'Dhuhr', 'time': '12:30'},
    {'name': 'Asr', 'time': '16:10'},
    {'name': 'Maghrib', 'time': '18:15'},
    {'name': 'Isha', 'time': '19:30'},
  ];

  int get _nextIndex {
    final now = TimeOfDay.now();
    for (var i = 0; i < _data.length; i++) {
      final parts = (_data[i]['time'] as String).split(':');
      final hour = int.tryParse(parts.first) ?? 0;
      final minute = int.tryParse(parts.last) ?? 0;
      if (hour > now.hour || (hour == now.hour && minute >= now.minute)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(
          children: List.generate(_data.length, (index) {
            final item = _data[index];
            final isNext = index == _nextIndex;

            return Padding(
              padding: EdgeInsets.only(
                  right: index == _data.length - 1 ? 0 : AppSpacing.md),
              child: SizedBox(
                width: AppSizes.prayerCardWidth,
                height: AppSizes.prayerCardHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PressableCard(
                      onTap: widget.onOpenPrayerScreen,
                      glow: isNext,
                      backgroundColor: isNext
                          ? context.palette.bgElevated
                          : context.palette.bgSurface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['name']!,
                            style: textTheme.labelSmall?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item['time']!,
                            style: textTheme.titleMedium?.copyWith(
                              color: context.palette.goldPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (isNext)
                      Positioned(
                        top: -AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: const GoldBadge(label: 'Next', compact: true),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
