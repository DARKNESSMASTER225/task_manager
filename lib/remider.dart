import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'my_drawer.dart'; // Импортируем файл с боковой панелью

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
  }

  void _initializeNotifications() {
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleAlarm(TimeOfDay time) async {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(Duration(days: 1));
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(alarmTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: 'alarm_sound.aiff',
    );

    final notificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Alarm',
      'Your alarm is ringing!',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Vibrate when the alarm goes off
    Vibration.vibrate(duration: 1000);
  }

  void _setAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _scheduleAlarm(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Напоминания', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Увеличен размер шрифта
      ),
      drawer: MyDrawer(), // Добавляем боковую панель
      body: Padding( // Добавляем отступы
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Выравниваем по вертикали
          children: [
            if (_selectedTime != null)
              Text('Напоминание установлено на: ${_selectedTime!.format(context)}', style: TextStyle(fontSize: 20)), // Увеличен размер шрифта
            SizedBox(height: 40), // Увеличили размер отступа
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Изменяем цвет кнопки на зеленый
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 24,
                    color: Colors.white, // Изменяем цвет текста на белый
                  ),
                ),
                onPressed: _setAlarm,
                child: Text('Установить напоминание'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}