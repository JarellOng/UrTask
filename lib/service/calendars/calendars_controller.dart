import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urtask/service/calendars/calendars_constants.dart';
import 'package:urtask/service/calendars/calendars_model.dart';

class CalendarController {
  final calendars = FirebaseFirestore.instance.collection("calendar");
  final userId = "admin";

  static final CalendarController _shared =
      CalendarController._sharedInstance();
  CalendarController._sharedInstance();
  factory CalendarController() => _shared;

  Future<Calendars> get() async {
    final querySnapshot =
        await calendars.where(calendarUserIdField, isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => Calendars.fromSnapshot(doc)).first;
  }
}
