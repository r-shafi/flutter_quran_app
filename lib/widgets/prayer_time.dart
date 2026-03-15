import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../models/prayer_time.dart';
import 'package:quran_app/config/notification_service.dart';
import 'package:quran_app/pages/location_setter.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<PrayerTimeModel> fetchPrayerTime() async {
  String city = await _prefs.then((SharedPreferences prefs) {
    return prefs.getString('city') ?? 'Sylhet';
  });
  String country = await _prefs.then((SharedPreferences prefs) {
    return prefs.getString('country') ?? 'Bangladesh';
  });

  final response = await http.get(
    Uri.parse(
      'https://api.aladhan.com/v1/hijriCalendarByCity?city=$city&country=$country',
    ),
  );

  if (response.statusCode == 200) {
    final model = PrayerTimeModel.fromMap(json.decode(response.body));
    final timingsList = model.data[DateTime.now().day - 1].timings.toMap();
    await NotificationService().schedulePrayerTimes(
        timingsList.map((k, v) => MapEntry(k.toString(), v.toString())));
    return model;
  } else {
    throw Exception('Failed to load post');
  }
}

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  Future<PrayerTimeModel> _futurePrayerTime = fetchPrayerTime();
  String _currentCity = 'Sylhet';
  String _currentCountry = 'Bangladesh';

  @override
  void initState() {
    super.initState();
    _loadLocationAndFetch();
  }

  Future<void> _loadLocationAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentCity = prefs.getString('city') ?? 'Sylhet';
      _currentCountry = prefs.getString('country') ?? 'Bangladesh';
      _futurePrayerTime = fetchPrayerTime();
    });
  }

  void refresh() {
    _loadLocationAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prayer Times - $_currentCity, $_currentCountry',
                style: textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.edit_location_alt),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSetter(),
                    ),
                  );
                  refresh();
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
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
                          image: DecorationImage(
                            image: AssetImage('assets/images/${entry.key}.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: textTheme.headlineSmall?.copyWith(
                                letterSpacing: 1,
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 25.0,
                                    color: colorScheme.scrim,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(
                                DateTime.parse(
                                  '0000-00-00 ${entry.value.toString().split(' ')[0]}:00',
                                ),
                              ),
                              style: textTheme.displaySmall?.copyWith(
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    blurRadius: 25.0,
                                    color: colorScheme.scrim,
                                  ),
                                ],
                              ),
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
              return const SizedBox(
                height: 210.0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
