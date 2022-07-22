import 'package:flutter/material.dart';
import 'package:quran_app/widgets/prayer_time.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran App'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: const [
            PrayerTime(),
          ],
        ),
      ),
    );
  }
}
