import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _city = 'Sylhet';
  String _country = 'Bangladesh';
  String _qari = 'Default';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _city = prefs.getString('city') ?? _city;
      _country = prefs.getString('country') ?? _country;
      _qari = prefs.getString('selectedVoice') ?? _qari;
    });
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required Widget trailing,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                color: context.palette.textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Settings'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SectionHeader(title: 'Appearance'),
            const SizedBox(height: AppSpacing.md),
            _row(
              context,
              label: 'Dark Theme',
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeModeChanged,
                activeThumbColor: context.palette.goldPrimary,
                inactiveTrackColor: context.palette.bgSubtle,
              ),
            ),
            _row(
              context,
              label: 'Arabic Font Size',
              trailing: SizedBox(
                width: AppSpacing.xxl * 2.5,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: context.palette.goldPrimary,
                    inactiveTrackColor: context.palette.bgSubtle,
                    thumbColor: context.palette.goldPrimary,
                  ),
                  child: Slider(
                    value: widget.arabicFontSize,
                    min: ArabicSize.minimum,
                    max: ArabicSize.ayahLarge + AppSpacing.lg / AppSpacing.sm,
                    divisions: 10,
                    onChanged: widget.onArabicFontSizeChanged,
                  ),
                ),
              ),
            ),
            const GoldDivider(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Notifications'),
            const SizedBox(height: AppSpacing.md),
            _row(
              context,
              label: 'Prayer Notifications',
              trailing: Switch(
                value: widget.notificationsEnabled,
                onChanged: widget.onNotificationsChanged,
                activeThumbColor: context.palette.goldPrimary,
                inactiveTrackColor: context.palette.bgSubtle,
              ),
            ),
            const GoldDivider(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Location'),
            const SizedBox(height: AppSpacing.md),
            _row(
              context,
              label: '$_city, $_country',
              trailing: GoldIconButton(
                icon: Icons.edit_rounded,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LocationSetter(),
                    ),
                  );
                  _loadPrefs();
                },
              ),
            ),
            const GoldDivider(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Audio'),
            const SizedBox(height: AppSpacing.md),
            _row(
              context,
              label: _qari,
              trailing: GoldIconButton(
                icon: Icons.chevron_right_rounded,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoicePicker(),
                    ),
                  );
                  _loadPrefs();
                },
              ),
            ),
            const GoldDivider(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'About'),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version 1.6.0',
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'License: Open Source',
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Repository: github.com/r-shafi/flutter_quran_app',
                    style: textTheme.labelSmall?.copyWith(
                      color: context.palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
