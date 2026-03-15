import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/config/design_tokens.dart';

class ArabicTextTheme extends ThemeExtension<ArabicTextTheme> {
  const ArabicTextTheme({
    required this.ayahStyle,
  });

  final TextStyle ayahStyle;

  @override
  ArabicTextTheme copyWith({TextStyle? ayahStyle}) {
    return ArabicTextTheme(
      ayahStyle: ayahStyle ?? this.ayahStyle,
    );
  }

  @override
  ArabicTextTheme lerp(ThemeExtension<ArabicTextTheme>? other, double t) {
    if (other is! ArabicTextTheme) {
      return this;
    }

    return ArabicTextTheme(
      ayahStyle: TextStyle.lerp(ayahStyle, other.ayahStyle, t) ?? ayahStyle,
    );
  }
}

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({required this.palette});

  final AppPalette palette;

  @override
  AppThemeColors copyWith({AppPalette? palette}) {
    return AppThemeColors(palette: palette ?? this.palette);
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      palette: AppPalette(
        bgDeep: Color.lerp(palette.bgDeep, other.palette.bgDeep, t) ??
            palette.bgDeep,
        bgSurface: Color.lerp(palette.bgSurface, other.palette.bgSurface, t) ??
            palette.bgSurface,
        bgElevated:
            Color.lerp(palette.bgElevated, other.palette.bgElevated, t) ??
                palette.bgElevated,
        bgSubtle: Color.lerp(palette.bgSubtle, other.palette.bgSubtle, t) ??
            palette.bgSubtle,
        goldPrimary:
            Color.lerp(palette.goldPrimary, other.palette.goldPrimary, t) ??
                palette.goldPrimary,
        goldMuted: Color.lerp(palette.goldMuted, other.palette.goldMuted, t) ??
            palette.goldMuted,
        goldGlow: Color.lerp(palette.goldGlow, other.palette.goldGlow, t) ??
            palette.goldGlow,
        textPrimary:
            Color.lerp(palette.textPrimary, other.palette.textPrimary, t) ??
                palette.textPrimary,
        textSecondary:
            Color.lerp(palette.textSecondary, other.palette.textSecondary, t) ??
                palette.textSecondary,
        textMuted: Color.lerp(palette.textMuted, other.palette.textMuted, t) ??
            palette.textMuted,
        error:
            Color.lerp(palette.error, other.palette.error, t) ?? palette.error,
        success: Color.lerp(palette.success, other.palette.success, t) ??
            palette.success,
        isDark: t < 0.5 ? palette.isDark : other.palette.isDark,
      ),
    );
  }
}

extension AppThemeX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppThemeColors>()!.palette;
}

class FadeOnlyPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeOnlyPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class AppTheme {
  static ThemeData light(double arabicFontSize) {
    return _buildTheme(AppPalette.light, arabicFontSize);
  }

  static ThemeData dark(double arabicFontSize) {
    return _buildTheme(AppPalette.dark, arabicFontSize);
  }

  static ThemeData _buildTheme(AppPalette palette, double arabicFontSize) {
    final colorScheme = ColorScheme(
      brightness: palette.isDark ? Brightness.dark : Brightness.light,
      primary: palette.goldPrimary,
      onPrimary: palette.bgDeep,
      secondary: palette.goldMuted,
      onSecondary: palette.textPrimary,
      error: palette.error,
      onError: palette.textPrimary,
      surface: palette.bgSurface,
      onSurface: palette.textPrimary,
      tertiary: palette.success,
      onTertiary: palette.bgDeep,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ).apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    );

    final appBarBorder = BorderSide(
      color: palette.goldMuted.withValues(alpha: 0.2),
      width: 1,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.bgDeep,
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeOnlyPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeOnlyPageTransitionsBuilder(),
          TargetPlatform.linux: FadeOnlyPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeOnlyPageTransitionsBuilder(),
          TargetPlatform.windows: FadeOnlyPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: palette.bgDeep,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: palette.textPrimary),
        systemOverlayStyle: palette.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        shape: Border(bottom: appBarBorder),
      ),
      cardTheme: CardThemeData(color: palette.bgSurface),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.bgDeep,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.bgElevated,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
      ),
      iconTheme: IconThemeData(color: palette.goldPrimary),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeColors(palette: palette),
        ArabicTextTheme(
          ayahStyle: TextStyle(
            fontFamily: 'Amiri',
            fontSize: arabicFontSize,
            fontWeight: FontWeight.w500,
            height: 2,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
