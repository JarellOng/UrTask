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

  Future<String> create({
    required String title,
    required String categoryId,
    required Timestamp start,
    required Timestamp end,
    required bool important,
    String? description,
  }) async {
    final events = await _getCollection();
    final test = await events.add({
      eventTitleField: title,
      eventCategoryIdField: categoryId,
      eventStartField: start,
      eventEndField: end,
      eventImportantField: important,
      eventDescriptionField: description
    });
    return test.id;
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
