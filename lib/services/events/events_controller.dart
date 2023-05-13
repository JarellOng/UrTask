import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/events/events_constants.dart';
import 'package:urtask/services/events/events_model.dart';

class EventController {
  final calendarController = CalendarController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar.id).collection(eventCollectionId);
  }

  static final EventController _shared = EventController._sharedInstance();
  EventController._sharedInstance();
  factory EventController() => _shared;

  Future<void> create({
    required String title,
    required String categoryId,
    required Timestamp start,
    required Timestamp end,
    required bool important,
    String? description,
  }) async {
    final events = await _getCollection();
    await events.add({
      eventTitleField: title,
      eventCategoryIdField: categoryId,
      eventStartField: start,
      eventEndField: end,
      eventImportantField: important,
      eventDescriptionField: description
    });
  }

  Future<Events> get({required String id}) async {
    final events = await _getCollection();
    final querySnapshot =
        await events.where(FieldPath.documentId, isEqualTo: id).get();
    return querySnapshot.docs.map((doc) => Events.fromSnapshot(doc)).first;
  }

  Stream<Iterable<Events>> getByDay({required DateTime dateTime}) async* {
    final events = await _getCollection();
    yield* events.snapshots().map((data) => data.docs
        .map((doc) => Events.fromSnapshot(doc))
        .where((element) => _isBetweenDate(
              start: element.start.toDate(),
              end: element.end.toDate(),
              compare: dateTime,
            )));
  }

  // TODO: Add Appropriate Start and End Datatypes
  Future<void> update({
    required String id,
    required String categoryId,
    required String title,
    required String description,
    required bool allDay,
    required bool important,
  }) async {
    final events = await _getCollection();
    await events.doc(id).update({
      eventCategoryIdField: categoryId,
      eventTitleField: title,
      eventDescriptionField: description,
      eventAllDayField: allDay,
      eventImportantField: important
    });
  }

  Future<void> delete({required String id}) async {
    final events = await _getCollection();
    await events.doc(id).delete();
  }

  static bool _isBetweenDate({
    required DateTime start,
    required DateTime end,
    required DateTime compare,
  }) {
    final startDay = start.day;
    final startMonth = start.month;
    final startYear = start.year;
    final endDay = end.day;
    final endMonth = end.month;
    final endYear = end.year;
    final compareDay = compare.day;
    final compareMonth = compare.month;
    final compareYear = compare.year;

    if (!(startDay <= compareDay && endDay >= compareDay)) return false;
    if (!(startMonth <= compareMonth && endMonth >= compareMonth)) return false;
    if (!(startYear <= compareYear && endYear >= compareYear)) return false;
    return true;
  }
}
