import 'package:flutter/material.dart';
import 'package:quran_app/core/di/injection_container.dart';
import 'package:quran_app/core/presentation/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}
