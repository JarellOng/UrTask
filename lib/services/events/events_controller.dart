
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return calendars.doc(calendar.id).collection(eventCollectionId);
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
        await events.where(FieldPath.documentId, isEqualTo: id).get();
    return querySnapshot.docs.map((doc) => Events.fromSnapshot(doc)).first;
  }

  Stream<Iterable<Events>> getByDate({required DateTime dateTime}) async* {
    final events = await _getCollection();
    yield* events.snapshots().map((data) => data.docs
        .map((doc) => Events.fromSnapshot(doc))
        .where((element) => _isBetweenDate(
              start: element.start.toDate(),
              end: element.end.toDate(),
              compare: dateTime,
            )));
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

  static bool _isBetweenDate({
    required DateTime start,
    required DateTime end,
    required DateTime compare,
  }) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    final compareDate = DateTime(compare.year, compare.month, compare.day);

    if (startDate.isAfter(compareDate) || endDate.isBefore(compareDate)) {
      return false;
    } else {
      return true;
    }
  }
}
