import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/notifications/notifications_constants.dart';
import 'package:urtask/services/notifications/notifications_model.dart';

class NotificationController {
  final calendarController = CalendarController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar!.id).collection(notificationCollectionId);
  }

  static ReceivedAction? initialAction;
  Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Notification',
          playSound: false,
          onlyAlertOnce: false,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
        )
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> schedulePushNotification({
    required String id,
    required String title,
    required String body,
    required Timestamp date,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id.hashCode,
        channelKey: 'alerts',
        title: title,
        body: body,
        summary: 'Reminder',
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.Messaging,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
          isDangerousOption: true,
        )
      ],
      schedule: NotificationCalendar.fromDate(
        date: date.toDate(),
      ),
    );
  }

  Future<void> cancelNotification({required String id}) async {
    await AwesomeNotifications().cancel(id.hashCode);
  }

  Future<void> create({
    required String eventId,
    required String eventTitle,
    required Timestamp dateTime,
    required NotificationTime time,
    required NotificationType type,
  }) async {
    final notifications = await _getCollection();
    final notification = await notifications.add({
      notificationEventIdField: eventId,
      notificationDateTimeField: dateTime,
      notificationTypeField: type.name,
    });

    late final String notificationDescription;
    if (time == NotificationTime.timeOfEvent) {
      notificationDescription = "The event has started!";
    } else if (time == NotificationTime.tenMinsBefore) {
      notificationDescription = "The event will start in 10 minutes!";
    } else if (time == NotificationTime.hourBefore) {
      notificationDescription = "The event will start in an hour!";
    } else if (time == NotificationTime.dayBefore) {
      notificationDescription = "The event will start in a day!";
    } else if (time == NotificationTime.custom) {
      notificationDescription = "Don't forget about this event!";
    }

    if (type == NotificationType.push) {
      await schedulePushNotification(
        id: notification.id,
        title: eventTitle,
        body: notificationDescription,
        date: dateTime,
      );
    }
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
      await cancelNotification(id: ids[i]);
    }
  }
}
