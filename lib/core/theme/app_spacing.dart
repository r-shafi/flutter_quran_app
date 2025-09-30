class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const double base = 4.0;

  // Spacing tokens
  static const double xs = base; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 4; // 16px
  static const double lg = base * 6; // 24px
  static const double xl = base * 8; // 32px
  static const double xxl = base * 12; // 48px
  static const double xxxl = base * 16; // 64px

  // Specific use cases
  static const double paddingSmall = sm;
  static const double paddingMedium = md;
  static const double paddingLarge = lg;

  static const double marginSmall = sm;
  static const double marginMedium = md;
  static const double marginLarge = lg;

  static const double borderRadius = sm;
  static const double borderRadiusMedium = md;
  static const double borderRadiusLarge = lg;

  static const double iconSizeSmall = md; // 16px
  static const double iconSizeMedium = lg; // 24px
  static const double iconSizeLarge = xl; // 32px
}
