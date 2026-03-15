import 'package:flutter/material.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    Key? key,
    required this.isDarkMode,
    required this.arabicFontSize,
    required this.onThemeModeChanged,
    required this.onArabicFontSizeChanged,
  }) : super(key: key);

  final bool isDarkMode;
  final double arabicFontSize;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<double> onArabicFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                'MADE WITH 🤍 BY SHAFI RAYHAN',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('Select Voice'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoicePicker(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mosque),
            title: const Text('Set Location'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSetter(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(
              'Dark Mode',
              style: textTheme.titleMedium,
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onThemeModeChanged,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(
              'Arabic Font Size',
              style: textTheme.titleMedium,
            ),
            subtitle: Slider(
              value: arabicFontSize,
              min: 18,
              max: 32,
              divisions: 14,
              label: arabicFontSize.round().toString(),
              onChanged: onArabicFontSizeChanged,
            ),
            trailing: Text(
              '${arabicFontSize.round()} sp',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
