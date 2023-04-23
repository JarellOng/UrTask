import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/service/events/events_constants.dart';

@immutable
class Events {
  final String id;
  final String categoryId;
  final String title;
  final Timestamp start;
  final Timestamp end;
  final String description;
  final bool allDay;
  final bool important;

  const Events({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
    required this.allDay,
    required this.important,
  });

  Events.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        categoryId = snapshot.data()[eventCategoryIdField],
        title = snapshot.data()[eventTitleField],
        start = snapshot.data()[eventStartField],
        end = snapshot.data()[eventEndField],
        description = snapshot.data()[eventDescriptionField],
        allDay = snapshot.data()[eventAllDayField],
        important = snapshot.data()[eventImportantField];
}
