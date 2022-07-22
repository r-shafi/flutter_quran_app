import 'package:flutter/material.dart';
import 'package:quran_app/pages/quran.dart';
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
          children: [
            const PrayerTime(),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              padding: const EdgeInsets.only(left: 30, right: 10, top: 10),
              width: double.infinity,
              child: ListTile(
                title: const Text('Quran'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Quran()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
