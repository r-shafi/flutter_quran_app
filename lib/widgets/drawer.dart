import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';
import 'package:quran_app/pages/bookmarks.dart';
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/pages/hadith.dart';
import 'package:quran_app/pages/azkar.dart';
import 'package:quran_app/pages/settings.dart';
import 'package:quran_app/presentation/widgets/geometric_pattern_painter.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
    required this.isDarkMode,
    required this.arabicFontSize,
    required this.notificationsEnabled,
    required this.onThemeModeChanged,
    required this.onArabicFontSizeChanged,
    required this.onNotificationsChanged,
    this.activeItem = 'Home',
  });

  final bool isDarkMode;
  final double arabicFontSize;
  final bool notificationsEnabled;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<double> onArabicFontSizeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final String activeItem;

  void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = label == activeItem;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppSpacing.xxl + AppSpacing.sm,
        decoration: BoxDecoration(
          color: isActive
              ? context.palette.bgElevated
              : AppColorValues.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.activeDrawerBarWidth,
              color: isActive
                  ? context.palette.goldPrimary
                  : AppColorValues.transparent,
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(icon, color: context.palette.goldPrimary),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: textTheme.titleMedium
                  ?.copyWith(color: context.palette.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.drawerOpen,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: FractionalTranslation(
            translation: Offset((1 - value) * -0.1, 0),
            child: child,
          ),
        );
      },
      child: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: AppSizes.drawerHeaderHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: context.palette.bgElevated),
                  const GeometricPatternLayer(opacity: 0.1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Quran App',
                          style: textTheme.displayLarge?.copyWith(
                            color: context.palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'تطبيق القرآن الكريم',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: ArabicSize.subtitle,
                            color: context.palette.goldPrimary,
                            height: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.palette.bgDeep,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _item(
                      context,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                    _item(
                      context,
                      icon: Icons.menu_book_rounded,
                      label: 'Quran',
                      onTap: () => _open(context, const Quran()),
                    ),
                    _item(
                      context,
                      icon: Icons.history_edu_rounded,
                      label: 'Hadith',
                      onTap: () => _open(context, const HadithScreen()),
                    ),
                    _item(
                      context,
                      icon: Icons.volunteer_activism_rounded,
                      label: 'Azkar',
                      onTap: () => _open(context, const AzkarScreen()),
                    ),
                    _item(
                      context,
                      icon: Icons.bookmark_rounded,
                      label: 'Bookmarks',
                      onTap: () => _open(context, const BookmarksScreen()),
                    ),
                    _item(
                      context,
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () => _open(
                        context,
                        SettingsScreen(
                          isDarkMode: isDarkMode,
                          arabicFontSize: arabicFontSize,
                          notificationsEnabled: notificationsEnabled,
                          onThemeModeChanged: onThemeModeChanged,
                          onArabicFontSizeChanged: onArabicFontSizeChanged,
                          onNotificationsChanged: onNotificationsChanged,
                        ),
                      ),
                    ),
                    _item(
                      context,
                      icon: Icons.record_voice_over_rounded,
                      label: 'Voice Picker',
                      onTap: () => _open(context, const VoicePicker()),
                    ),
                    _item(
                      context,
                      icon: Icons.place_rounded,
                      label: 'Location',
                      onTap: () => _open(context, const LocationSetter()),
                    ),
                  ],
                ),
              ),
            ),
            const GoldDivider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Version 1.6.0',
                  style: textTheme.labelSmall?.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
