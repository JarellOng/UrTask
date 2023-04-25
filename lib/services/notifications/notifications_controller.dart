import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/notifications/notifications_constants.dart';

class EventController {
  final calendarController = CalendarController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar.id).collection(notificationCollectionId);
  }

  static final EventController _shared = EventController._sharedInstance();
  EventController._sharedInstance();
  factory EventController() => _shared;

  Future<void> create({
    required String eventId,
    required DateTime dateTime,
    required NotificationType type,
  }) async {
    final notifications = await _getCollection();
    await notifications.add({
      notificationEventIdField: eventId,
      notificationDateTimeField: dateTime.millisecondsSinceEpoch,
      notificationTypeField: type.toString(),
    });
  }
}
