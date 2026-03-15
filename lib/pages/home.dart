import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/widgets/drawer.dart';
import 'package:quran_app/widgets/prayer_time.dart';

class Home extends StatelessWidget {
  const Home({
    Key? key,
    required this.isDarkMode,
    required this.arabicFontSize,
    required this.notificationsEnabled,
    required this.onThemeModeChanged,
    required this.onArabicFontSizeChanged,
    required this.onNotificationsChanged,
  }) : super(key: key);

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

    return Scaffold(
      drawer: SafeArea(
        child: SettingsDrawer(
          isDarkMode: isDarkMode,
          arabicFontSize: arabicFontSize,
          notificationsEnabled: notificationsEnabled,
          onThemeModeChanged: onThemeModeChanged,
          onArabicFontSizeChanged: onArabicFontSizeChanged,
          onNotificationsChanged: onNotificationsChanged,
        ),
      ),
      appBar: AppBar(
        title: const Text('Quran App'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
          const PrayerTime(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Quran(),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/quran.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.scrim.withValues(alpha: 0.8),
                            colorScheme.scrim.withValues(alpha: 0.3),
                            colorScheme.scrim.withValues(alpha: 0.01),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Text(
                        'Quran',
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AyahOfTheDay(),
        ],
      ),
    );
  }
}

class AyahOfTheDay extends StatefulWidget {
  const AyahOfTheDay({super.key});

  @override
  State<AyahOfTheDay> createState() => _AyahOfTheDayState();
}

class _AyahOfTheDayState extends State<AyahOfTheDay> {
  Map<String, dynamic>? _ayahData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAyahOfTheDay();
  }

  Future<void> _fetchAyahOfTheDay() async {
    try {
      final now = DateTime.now();
      final dayOfYear =
          int.parse("${now.difference(DateTime(now.year, 1, 1)).inDays}");
      final ayahIndex = (dayOfYear % 6236) + 1; // 6236 total ayahs in Quran

      final response = await http.get(Uri.parse(
          'https://api.alquran.cloud/v1/ayah/$ayahIndex/editions/quran-uthmani,en.sahih'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          _ayahData = {
            'arabic': data[0]['text'],
            'translation': data[1]['text'],
            'surah': data[0]['surah']['englishName'],
            'numberInSurah': data[0]['numberInSurah'],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayah of the Day',
            style: themeTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_ayahData != null) ...[
            Text(
              _ayahData!['arabic'],
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 22,
                color: colorScheme.onSecondaryContainer,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _ayahData!['translation'],
              style: themeTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- Surah ${_ayahData!['surah']}, Ayah ${_ayahData!['numberInSurah']}',
                style: themeTheme.labelMedium?.copyWith(
                  color:
                      colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else
            Text(
              'Could not load Ayah of the Day',
              style: themeTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
