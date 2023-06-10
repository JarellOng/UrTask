import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/calendars/calendars_constants.dart';
import 'calendars_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class CalendarController {
  final calendars = FirebaseFirestore.instance.collection("calendar");

  static final CalendarController _shared =
      CalendarController._sharedInstance();
  CalendarController._sharedInstance();
  factory CalendarController() => _shared;

  Future<void> create({required String userId}) async {
    await calendars.add({calendarUserIdField: userId});
  }

  Future<Calendars?> get() async {
    final currentUser = AuthService.firebase().currentUser!;
    final querySnapshot = await calendars
        .where(calendarUserIdField, isEqualTo: currentUser.id)
        .limit(1)
        .get();
    return querySnapshot.docs
        .map((doc) => Calendars.fromSnapshot(doc))
        .firstOrNull;
  }

  Future<Calendars> getPreset() async {
    final querySnapshot = await calendars
        .where(calendarUserIdField, isEqualTo: calendarAdminUserId)
        .limit(1)
        .get();
    return querySnapshot.docs.map((doc) => Calendars.fromSnapshot(doc)).first;
  }

  DateTime? showToday({required TextEditingController today}) {
    if (today.text == "Today") {
      today.text = "";
      return DateTime.now();
    }
    return null;
  }
}
