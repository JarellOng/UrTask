import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/enums/custom_notification_uot_enum.dart';
import 'package:urtask/enums/notification_time_enum.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/events/events_constants.dart';
import 'package:urtask/services/events/events_model.dart';
import 'package:urtask/services/notifications/notifications_controller.dart';

class EventController {
  final calendarController = CalendarController();
  final notificationController = NotificationController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar!.id).collection(eventCollectionId);
  }

  static final EventController _shared = EventController._sharedInstance();
  EventController._sharedInstance();
  factory EventController() => _shared;

  Future<String> create({
    required String title,
    required String categoryId,
    String? groupId,
    required Timestamp start,
    required Timestamp end,
    required bool important,
    String? description,
  }) async {
    final events = await _getCollection();
    final event = await events.add({
      eventTitleField: title,
      eventCategoryIdField: categoryId,
      eventGroupIdField: groupId,
      eventStartField: start,
      eventEndField: end,
      eventImportantField: important,
      eventDescriptionField: description
    });
    return event.id;
  }

  Future<Events> get({required String id}) async {
    final events = await _getCollection();
    final querySnapshot =
        await events.where(FieldPath.documentId, isEqualTo: id).limit(1).get();
    return querySnapshot.docs.map((doc) => Events.fromSnapshot(doc)).first;
  }

  Stream<Iterable<Events>> getByDate({required DateTime dateTime}) async* {
    final events = await _getCollection();
    yield* events
        .orderBy(eventImportantField, descending: true)
        .orderBy(eventStartField)
        .snapshots()
        .map((data) => data.docs
            .map((doc) => Events.fromSnapshot(doc))
            .where((element) => DateTimeHelper.isBetweenDate(
                  start: element.start.toDate(),
                  end: element.end.toDate(),
                  compare: dateTime,
                )));
  }

  Future<Map<DateTime, List<Events>>> getAllMarker() async {
    final events = await _getCollection();
    final eventList = await events
        .snapshots()
        .map((data) => data.docs.map((doc) => Events.fromSnapshot(doc)))
        .first;
    Map<DateTime, List<Events>> eventMap = {};
    for (var event in eventList) {
      final start = event.start.toDate();
      final end = event.end.toDate();
      var startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      // if (startDate != endDate) {
      //   while (start != endDate) {
      //     if (eventMap[startDate] == null) {
      //       eventMap[startDate] = [];
      //     }
      //     eventMap[startDate]!.add(event);
      //     startDate.add(const Duration(days: 1));
      //   }
      // }
      // else {
      if (eventMap[startDate] == null) {
        eventMap[startDate] = [];
      }
      eventMap[startDate]!.add(event);
      // }
    }
    return eventMap;
  }

  Future<void> update({
    required String id,
    required String title,
    required String categoryId,
    required Timestamp start,
    required Timestamp end,
    required bool important,
    String? description,
  }) async {
    final events = await _getCollection();
    await events.doc(id).update({
      eventTitleField: title,
      eventCategoryIdField: categoryId,
      eventStartField: start,
      eventEndField: end,
      eventImportantField: important,
      eventDescriptionField: description
    });
  }

  Future<void> delete({required String id}) async {
    final events = await _getCollection();
    await events.doc(id).delete();
  }

  Future<void> bulkDeleteByGroupId({required String id}) async {
    final events = await _getCollection();
    final querySnapshot =
        await events.where(eventGroupIdField, isEqualTo: id).get();
    for (var element in querySnapshot.docs) {
      await events.doc(element.id).delete();
      final notificationIds = await notificationController
          .getByEventId(id: element.id)
          .then((value) => value.map((e) => e.id).toList());
      await notificationController.bulkDelete(ids: notificationIds);
    }
  }

  Future<void> bulkDeleteByCategoryId({required String id}) async {
    final events = await _getCollection();
    final querySnapshot =
        await events.where(eventCategoryIdField, isEqualTo: id).get();
    for (var element in querySnapshot.docs) {
      await events.doc(element.id).delete();
      final notificationIds = await notificationController
          .getByEventId(id: element.id)
          .then((value) => value.map((e) => e.id).toList());
      await notificationController.bulkDelete(ids: notificationIds);
    }
  }

  Future<List<Events>> search({required String query}) async {
    final events = FirebaseFirestore.instance.collection('events');
    final querySnapshot = await events.get();
    if (query.isEmpty) {
      return querySnapshot.docs.map((doc) => Events.fromSnapshot(doc)).toList();
    } else {
      return querySnapshot.docs
          .map((doc) => Events.fromSnapshot(doc))
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  String printSelectedRepeat({
    required RepeatType type,
    required int typeAmount,
    required RepeatDuration duration,
    int? durationAmount,
    DateTime? durationDate,
  }) {
    String repeatString = "";

    if (type == RepeatType.noRepeat) {
      repeatString += "Don't repeat";
    } else if (type == RepeatType.perDay) {
      if (typeAmount <= 1) {
        repeatString += "Everyday";
      } else {
        repeatString += "Every $typeAmount days";
      }
    } else if (type == RepeatType.perMonth) {
      if (typeAmount <= 1) {
        repeatString += "Every month";
      } else {
        repeatString += "Every $typeAmount months";
      }
    } else if (type == RepeatType.perWeek) {
      if (typeAmount <= 1) {
        repeatString += "Every week";
      } else {
        repeatString += "Every $typeAmount weeks";
      }
    } else if (type == RepeatType.perYear) {
      if (typeAmount <= 1) {
        repeatString += "Every year";
      } else {
        repeatString += "Every $typeAmount years";
      }
    }

    if (durationAmount != null) {
      if (durationAmount <= 1) {
        repeatString += " (once)";
      } else {
        repeatString += " ($durationAmount times)";
      }
    } else if (durationDate != null) {
      final day = durationDate.day - 1;
      final month = durationDate.month - 1;
      final year = durationDate.year;
      repeatString += " until ${DateTimeHelper.dateToString(
        month: month,
        day: day,
        year: year,
      )}";
    }
    return repeatString;
  }

  String printSelectedNotifications({
    required bool flag,
    required Map<NotificationTime, NotificationType> selectedNotifications,
  }) {
    String notificationString = "";
    if (flag == false) {
      notificationString += "No notifications";
    } else {
      final notificationAmount = selectedNotifications.values.length;
      if (notificationAmount <= 1) {
        notificationString += "1 notification";
      } else {
        notificationString += "$notificationAmount notifications";
      }
    }

    return notificationString;
  }

  String printCustomNotification({required int amount, required int uot}) {
    if (amount == 0) {
      return "At time of event";
    }

    final uotName = CustomNotificationUOT.values.elementAt(uot).name;
    return "$amount $uotName before";
  }
}
