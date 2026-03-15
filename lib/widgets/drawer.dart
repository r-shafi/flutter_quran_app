import 'package:flutter/material.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/pages/voice_picker.dart';
import 'package:quran_app/pages/bookmarks.dart';
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/pages/hadith.dart';
import 'package:quran_app/pages/azkar.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
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
                'ISLAMIC APP',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Quran'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Quran()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Hadith'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HadithScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('Azkar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AzkarScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BookmarksScreen()),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child:
                Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(
              'Prayer Notifications',
              style: textTheme.titleMedium,
            ),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ),
        ],
      ),
    );
  }
}
