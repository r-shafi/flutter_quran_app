import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

class ArabicSize {
  static const double minimum = 22.0;
  static const double hadith = 20.0;
  static const double ayah = 24.0;
  static const double ayahLarge = 26.0;
  static const double subtitle = 14.0;
  static const double surahName = 16.0;
}

class AppDurations {
  static const Duration pressScale = Duration(milliseconds: 120);
  static const Duration drawerOpen = Duration(milliseconds: 250);
  static const Duration screenFade = Duration(milliseconds: 200);
  static const Duration listStaggerStep = Duration(milliseconds: 30);
  static const Duration ayahPulse = Duration(milliseconds: 1200);
  static const Duration playBreath = Duration(milliseconds: 1800);
  static const Duration heroPatternRotation = Duration(seconds: 60);
}

class AppSizes {
  static const double dividerThickness = 1.0;
  static const double appBarBorder = 1.0;
  static const double iconButton = 40.0;
  static const double iconButtonSmall = 32.0;
  static const double playButton = 56.0;
  static const double drawerHeaderHeight = 200.0;
  static const double heroHeight = 220.0;
  static const double prayerCardWidth = 80.0;
  static const double prayerCardHeight = 90.0;
  static const double quickTile = 150.0;
  static const double audioBarHeight = 96.0;
  static const double ayahBadgeSize = 32.0;
  static const double sectionBarWidth = 3.0;
  static const double sectionBarHeight = 20.0;
  static const double cardAccentWidth = 4.0;
  static const double activeDrawerBarWidth = 3.0;
  static const double tabIndicatorThickness = 2.0;
}

class AppColorValues {
  static const Color transparent = Color(0x00000000);
}

class AppShadows {
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1AD4A847),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x4DD4A847),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];
}

class AppPalette {
  const AppPalette({
    required this.bgDeep,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgSubtle,
    required this.goldPrimary,
    required this.goldMuted,
    required this.goldGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.error,
    required this.success,
    required this.isDark,
  });

  final Color bgDeep;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgSubtle;
  final Color goldPrimary;
  final Color goldMuted;
  final Color goldGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color error;
  final Color success;
  final bool isDark;

  static const AppPalette dark = AppPalette(
    bgDeep: Color(0xFF0A0E1A),
    bgSurface: Color(0xFF111827),
    bgElevated: Color(0xFF1A2235),
    bgSubtle: Color(0xFF243048),
    goldPrimary: Color(0xFFD4A847),
    goldMuted: Color(0xFF8A6E30),
    goldGlow: Color(0x33D4A847),
    textPrimary: Color(0xFFF2EBD9),
    textSecondary: Color(0xFFB8A98A),
    textMuted: Color(0xFF6B5E48),
    error: Color(0xFFE05252),
    success: Color(0xFF4CAF7D),
    isDark: true,
  );

  static const AppPalette light = AppPalette(
    bgDeep: Color(0xFFFAF6EE),
    bgSurface: Color(0xFFF0E9D8),
    bgElevated: Color(0xFFF6EFE0),
    bgSubtle: Color(0xFFE7DCC5),
    goldPrimary: Color(0xFFD4A847),
    goldMuted: Color(0xFF8A6E30),
    goldGlow: Color(0x33D4A847),
    textPrimary: Color(0xFF1A1208),
    textSecondary: Color(0xFF5A4A35),
    textMuted: Color(0xFF8A775C),
    error: Color(0xFFE05252),
    success: Color(0xFF4CAF7D),
    isDark: false,
  );
}
