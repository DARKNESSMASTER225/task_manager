import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'home_screen.dart'; // Замените на имя вашего файла с начальным экраном
import 'profile_screen.dart'; // Замените на имя файла с профилем
import 'archive_screen.dart';
import 'setting.dart';
import 'do_line.dart';
import 'remider.dart';
import 'alarm_page.dart'; // Добавьте импорт для страницы будильника
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

int notification_period = 1;
int notification_time = 12;

Future<void> scheduleDailyReminderNotification() async {
  // Инициализация плагина для локальных уведомлений
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Инициализация настроек для Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');


  // Инициализация настроек для плагина
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Инициализация плагина с настройками
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Настройка временной зоны
  tz.initializeTimeZones();
  final tz.Location location = tz.getLocation('Europe/Moscow'); // Установите свою временную зону

  // Время для ежедневного уведомления (например, 10:00 утра)
  final tz.TZDateTime now = tz.TZDateTime.now(location);
  tz.TZDateTime scheduledDate = tz.TZDateTime(location, now.year, now.month,
      now.day, notification_time); // Измените время, если нужно
  if (scheduledDate.isBefore(now)) {
    DateTime scheduledDate = DateTime.now(); // Get the current date
    scheduledDate = scheduledDate.add(Duration(days: notification_period));
  }

  // Детали уведомления
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // Планирование повторяющегося уведомления
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Напоминание о задачах',
    'У вас ещё остались невыполненные задачи! Не забудьте о них.',
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: 'your payload',
  );
}


class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  MyApp() {
    _initializeNotifications();
    _scheduleDailyNotification();
  }

  void _initializeNotifications() {
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  void _scheduleDailyNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel_id',
      'Daily Reminder Channel',
      channelDescription: 'Channel for daily task reminders',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: 'notification_sound.aiff',
    );

    final notificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0, 0);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Reminder',
      'У вас ещё остались невыполненные задачи!',
      scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Начальный экран
      // Добавьте routes для других экранов
      routes: {
        '/archive': (context) => ArchiveScreen(),
        '/setting': (context) => SettingsPage(),
        '/stat': (context) => CalendarPage(),
        '/alarm': (context) => AlarmPage(),
      },
    );
  }
}
