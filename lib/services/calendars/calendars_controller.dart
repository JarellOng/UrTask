import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/calendars/calendars_constants.dart';
import 'calendars_model.dart';

class CalendarController {
  final calendars = FirebaseFirestore.instance.collection("calendar");
  final userId = AuthService.firebase().currentUser!.id;

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
