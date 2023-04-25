import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/services/notifications/notifications_constants.dart';

@immutable
class Notfications {
  final String id;
  final String eventId;
  final DateTime dateTime;
  final Enum type;

  const Notfications({
    required this.id,
    required this.eventId,
    required this.dateTime,
    required this.type,
  });

  Notfications.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        eventId = snapshot.data()[notificationEventIdField],
        dateTime = DateTime.fromMillisecondsSinceEpoch(
            snapshot.data()[notificationDateTimeField]),
        type = NotificationType.values.firstWhere((element) =>
            element.toString() ==
            "NotificationType.${snapshot.data()[notificationTypeField]}");
}
