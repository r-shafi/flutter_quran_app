import 'package:flutter/material.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final arabicFontSize = prefs.getDouble('arabicFontSize') ?? 22;

  runApp(
    App(
      initialIsDarkMode: isDarkMode,
      initialArabicFontSize: arabicFontSize,
      prefs: prefs,
    ),
  );
}

class App extends StatefulWidget {
  const App({
    Key? key,
    required this.initialIsDarkMode,
    required this.initialArabicFontSize,
    required this.prefs,
  }) : super(key: key);

  final bool initialIsDarkMode;
  final double initialArabicFontSize;
  final SharedPreferences prefs;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late bool _isDarkMode;
  late double _arabicFontSize;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialIsDarkMode;
    _arabicFontSize = widget.initialArabicFontSize;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(
        isDarkMode: _isDarkMode,
        arabicFontSize: _arabicFontSize,
        onThemeModeChanged: _toggleDarkMode,
        onArabicFontSizeChanged: _setArabicFontSize,
      ),
      theme: AppTheme.light(_arabicFontSize),
      darkTheme: AppTheme.dark(_arabicFontSize),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
