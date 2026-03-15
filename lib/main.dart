import 'package:flutter/material.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_app/audio_handler.dart';
import 'package:quran_app/config/notification_service.dart';

late MyAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rshafi.quranapp.channel.audio',
      androidNotificationChannelName: 'Quran Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();

  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final arabicFontSize = prefs.getDouble('arabicFontSize') ?? 22;
  final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

  runApp(
    App(
      initialIsDarkMode: isDarkMode,
      initialArabicFontSize: arabicFontSize,
      initialNotificationsEnabled: notificationsEnabled,
      prefs: prefs,
    ),
  );
}

class App extends StatefulWidget {
  const App({
    super.key,
    required this.initialIsDarkMode,
    required this.initialArabicFontSize,
    required this.initialNotificationsEnabled,
    required this.prefs,
  });

  final bool initialIsDarkMode;
  final double initialArabicFontSize;
  final bool initialNotificationsEnabled;
  final SharedPreferences prefs;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late bool _isDarkMode;
  late double _arabicFontSize;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialIsDarkMode;
    _arabicFontSize = widget.initialArabicFontSize;
    _notificationsEnabled = widget.initialNotificationsEnabled;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_notificationsEnabled) {
        NotificationService().requestPermissionsSafely();
      }
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    await widget.prefs.setBool('isDarkMode', value);
  }

  Future<void> _setArabicFontSize(double value) async {
    setState(() {
      _arabicFontSize = value;
    });
    await widget.prefs.setDouble('arabicFontSize', value);
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await widget.prefs.setBool('notificationsEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(
        isDarkMode: _isDarkMode,
        arabicFontSize: _arabicFontSize,
        notificationsEnabled: _notificationsEnabled,
        onThemeModeChanged: _toggleDarkMode,
        onArabicFontSizeChanged: _setArabicFontSize,
        onNotificationsChanged: _setNotificationsEnabled,
      ),
      theme: AppTheme.light(_arabicFontSize),
      darkTheme: AppTheme.dark(_arabicFontSize),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
