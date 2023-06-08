import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/notifications/notifications_constants.dart';
import 'package:urtask/services/notifications/notifications_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationController {
  final calendarController = CalendarController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar!.id).collection(notificationCollectionId);
  }

  static final NotificationController _shared =
      NotificationController._sharedInstance();
  NotificationController._sharedInstance();
  factory NotificationController() => _shared;

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> create({
    required String eventId,
    required Timestamp dateTime,
    required String type,
  }) async {
    final notifications = await _getCollection();
    await notifications.add({
      notificationEventIdField: eventId,
      notificationDateTimeField: dateTime,
      notificationTypeField: type,
    });
  }

  Future<Iterable<Notifications>> getByEventId({required String id}) async {
    final notifications = await _getCollection();
    final querySnapshot = await notifications
        .where(notificationEventIdField, isEqualTo: id)
        .limit(5)
        .get();
    return querySnapshot.docs.map((doc) => Notifications.fromSnapshot(doc));
  }

  Future<void> bulkDelete({required List<String> ids}) async {
    final notifications = await _getCollection();
    for (var i = 0; i < ids.length; i++) {
      await notifications.doc(ids[i]).delete();
    }
  }
}
