import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/services/calendars/calendars_constants.dart';

@immutable
class Calendars {
  final String id;
  final String userId;

  const Calendars({
    required this.id,
    required this.userId,
  });

  Calendars.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[calendarUserIdField];
}
