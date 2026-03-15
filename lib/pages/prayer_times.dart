import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/notification_service.dart';
import 'package:quran_app/config/theme.dart';
import 'package:quran_app/models/prayer_time.dart';
import 'package:quran_app/pages/location_setter.dart';
import 'package:quran_app/presentation/widgets/app_card.dart';
import 'package:quran_app/presentation/widgets/gold_badge.dart';
import 'package:quran_app/presentation/widgets/gold_divider.dart';
import 'package:quran_app/presentation/widgets/gold_icon_button.dart';
import 'package:quran_app/presentation/widgets/lux_app_bar.dart';
import 'package:quran_app/presentation/widgets/screen_background.dart';
import 'package:quran_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late Future<PrayerTimeModel> _futurePrayer;
  String _city = 'Sylhet';
  String _country = 'Bangladesh';
  bool _notify = true;

  @override
  void initState() {
    super.initState();
    _futurePrayer = _fetchPrayer();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _city = prefs.getString('city') ?? _city;
      _country = prefs.getString('country') ?? _country;
      _notify = prefs.getBool('notificationsEnabled') ?? _notify;
      _futurePrayer = _fetchPrayer();
    });
  }

  Future<PrayerTimeModel> _fetchPrayer() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('city') ?? _city;
    final country = prefs.getString('country') ?? _country;

    final response = await http.get(
      Uri.parse(
        'https://api.aladhan.com/v1/hijriCalendarByCity?city=$city&country=$country',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load prayer times');
    }

    final model = PrayerTimeModel.fromMap(jsonDecode(response.body));
    final timings = model.data[DateTime.now().day - 1].timings.toMap();
    await NotificationService().schedulePrayerTimes(
      timings.map((k, v) => MapEntry(k.toString(), v.toString())),
    );

    return model;
  }

  int _nextPrayerIndex(List<MapEntry<String, dynamic>> entries) {
    final now = TimeOfDay.now();
    for (var i = 0; i < entries.length; i++) {
      final clean = entries[i].value.toString().split(' ').first;
      final parts = clean.split(':');
      final hour = int.tryParse(parts.first) ?? 0;
      final minute = int.tryParse(parts.last) ?? 0;
      if (hour > now.hour || (hour == now.hour && minute >= now.minute)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const LuxAppBar(
        title: Text('Prayer Times'),
        showBack: true,
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SectionHeader(
              title: 'Prayer Times',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_city, $_country',
                    style: textTheme.labelSmall?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GoldIconButton(
                    icon: Icons.edit_location_alt_rounded,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationSetter(),
                        ),
                      );
                      _loadPrefs();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<PrayerTimeModel>(
              future: _futurePrayer,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError) {
                    return AppCard(
                      child: Text(
                        '${snapshot.error}',
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                final day = snapshot.data!.data[DateTime.now().day - 1];
                final map = day.timings
                    .toMap()
                    .entries
                    .where((e) =>
                        e.key == 'Fajr' ||
                        e.key == 'Dhuhr' ||
                        e.key == 'Asr' ||
                        e.key == 'Maghrib' ||
                        e.key == 'Isha')
                    .toList();
                final nextIndex = _nextPrayerIndex(map);

                return Column(
                  children: [
                    AppCard(
                      glow: true,
                      backgroundColor: context.palette.bgElevated,
                      child: Column(
                        children: [
                          Text(
                            day.date.hijri.date,
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            day.date.gregorian.date,
                            style: textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        children: List.generate(map.length, (index) {
                          final row = map[index];
                          final isNext = index == nextIndex;

                          return Container(
                            color: isNext
                                ? context.palette.bgElevated
                                : AppColorValues.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      row.key,
                                      style: textTheme.titleMedium,
                                    ),
                                    if (isNext) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      const GoldBadge(
                                          label: 'Next', compact: true),
                                    ],
                                    const Spacer(),
                                    Text(
                                      row.value.toString().split(' ').first,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: context.palette.goldPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (index != map.length - 1)
                                  const GoldDivider(),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Prayer Notifications',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          Switch(
                            value: _notify,
                            onChanged: (value) async {
                              setState(() => _notify = value);
                              await NotificationService()
                                  .toggleNotifications(value);
                            },
                            activeThumbColor: context.palette.goldPrimary,
                            inactiveTrackColor: context.palette.goldMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
