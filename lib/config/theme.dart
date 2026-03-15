import 'package:flutter/material.dart';

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

class AppTheme {
  static ThemeData light(double arabicFontSize) {
    const seedColor = Color(0xFF0B6E4F);
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return _buildTheme(scheme, arabicFontSize);
  }

  static ThemeData dark(double arabicFontSize) {
    const seedColor = Color(0xFF0B6E4F);
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(scheme, arabicFontSize);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, double arabicFontSize) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
      ),
      extensions: <ThemeExtension<dynamic>>[
        ArabicTextTheme(
          ayahStyle: TextStyle(
            fontFamily: 'Amiri',
            fontSize: arabicFontSize,
            fontWeight: FontWeight.w500,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
