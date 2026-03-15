import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> requestPermissionsSafely() async {
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (_) {
      // Ignore startup permission plugin edge cases and retry later from UI.
    }
  }

  Future<bool> _areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? false;
  }

  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (value) {
      await requestPermissionsSafely();
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<void> schedulePrayerTimes(Map<String, String> timings) async {
    if (!await _areNotificationsEnabled()) return;

    await flutterLocalNotificationsPlugin.cancelAll();

    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 0; i < prayers.length; i++) {
      final name = prayers[i];
      final timeString = timings[name.toLowerCase()] ??
          timings[name]; // depending on API casing
      if (timeString == null) continue;

      final timeParts = timeString.split(' ')[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: i,
        title: name,
        body: "It's time for $name",
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_times',
            'Prayer Times',
            channelDescription: 'Notifications for daily prayer times',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
