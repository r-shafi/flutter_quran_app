import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './../models/prayer_time.dart';

Future<PrayerTimeModel> fetchPrayerTime() async {
  final response = await http.get(Uri.parse(
      'https://api.aladhan.com/v1/hijriCalendarByCity?city=Sylhet&country=Bangladesh'));

  if (response.statusCode == 200) {
    return PrayerTimeModel.fromMap(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class PrayerTime extends StatefulWidget {
  const PrayerTime({Key? key}) : super(key: key);

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  late Future<PrayerTimeModel> _futurePrayerTime;

  @override
  void initState() {
    super.initState();
    _futurePrayerTime = fetchPrayerTime();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futurePrayerTime,
        builder: (context, AsyncSnapshot<PrayerTimeModel> snapshot) {
          if (snapshot.hasData) {
            return CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
              ),
              items: snapshot.data!.data[DateTime.now().day - 1].timings
                  .toMap()
                  .entries
                  .map((entry) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(.3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style:
                                const TextStyle(fontSize: 25, letterSpacing: 1),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(DateTime.parse(
                                '0000-00-00 ${entry.value.toString().split(' ')[0]}:00')),
                            style: const TextStyle(fontSize: 35.0),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            return const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ));
          }
        });
  }
}
