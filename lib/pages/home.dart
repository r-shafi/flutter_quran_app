import 'package:flutter/material.dart';
import 'package:quran_app/pages/quran.dart';
import 'package:quran_app/widgets/drawer.dart';
import 'package:quran_app/widgets/prayer_time.dart';

class Home extends StatelessWidget {
  const Home({
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

    return Scaffold(
      drawer: SafeArea(
        child: SettingsDrawer(
          isDarkMode: isDarkMode,
          arabicFontSize: arabicFontSize,
          onThemeModeChanged: onThemeModeChanged,
          onArabicFontSizeChanged: onArabicFontSizeChanged,
        ),
      ),
      appBar: AppBar(
        title: const Text('Quran App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
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
                              colorScheme.scrim.withOpacity(0.8),
                              colorScheme.scrim.withOpacity(0.3),
                              colorScheme.scrim.withOpacity(0.01),
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
          ],
        ),
      ),
    );
  }
}
