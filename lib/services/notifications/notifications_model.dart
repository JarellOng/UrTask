import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/enums/notification_type_enum.dart';
import 'package:urtask/services/notifications/notifications_constants.dart';

@immutable
class Notifications {
  final String id;
  final String eventId;
  final Timestamp dateTime;
  final NotificationType type;

  const Notifications({
    required this.id,
    required this.eventId,
    required this.dateTime,
    required this.type,
  });

  Notifications.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        eventId = snapshot.data()[notificationEventIdField],
        dateTime = snapshot.data()[notificationDateTimeField],
        type = NotificationType.values.firstWhere((element) =>
            element.name.toString() ==
            "${snapshot.data()[notificationTypeField]}");
}
