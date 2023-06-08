import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'navigategate.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocalNotificationCustom {
  static ReceivedAction? initialAction;
  static Future<void> showNotification(
      String title, String body, Timestamp date) async {
    Random random = Random();

    int randomNumber = random.nextInt(30);
    int notifId = randomNumber;
    var datetime = tz.TZDateTime.from(date.toDate(), tz.local);
    flutterLocalNotificationsPlugin.zonedSchedule(
      notifId,
      title,
      body,
      datetime,
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            importance: Importance.max, priority: Priority.max),
        // iOS details
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle:
          true, //To show notification even when the app is closed
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> notificationHandler(
      GlobalKey<NavigatorState> navigatorKey) async {
    // Pengaturan Notifikasi

    // AndroidInitializationSettings default value is 'app_icon'
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Handling notifikasi yang di tap oleh pengguna
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      print(payload);
      if (payload != null) {
        NavigatorNavigate().go(navigatorKey, 'login');
      }
    });
  }

  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        'resource://drawable/app_icon', //
        [
          NotificationChannel(
            channelKey: 'alerts',
            channelName: 'Alerts',
            channelDescription: 'Notification',
            playSound: true,
            onlyAlertOnce: true,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
          )
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> scheduleNewNotification(
      String title, String body, Timestamp date,
      {repeat = false}) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) isAllowed = await displayNotificationRationale();
    // if (!isAllowed) return;
    Random random = Random();
    int randomNumber = random.nextInt(30);
    int notifId = randomNumber;
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId, // -1 is replaced by a random number
          channelKey: 'alerts',
          title: title,
          body: body,
          summary: 'Reminder',
          category: NotificationCategory.Reminder,

          // bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
          // largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
          //'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.Messaging,

          // payload: {'notificationId': '1234567890'}
        ),
        actionButtons: [
          // NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ],
        schedule: NotificationCalendar.fromDate(
            date: date.toDate(), repeats: repeat));
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
