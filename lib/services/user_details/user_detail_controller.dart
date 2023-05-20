import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/user_details/user_details_constants.dart';
import 'package:urtask/services/user_details/user_details_model.dart';

class UserDetailController {
  final userDetails = FirebaseFirestore.instance.collection("userDetail");

  static final UserDetailController _shared =
      UserDetailController._sharedInstance();
  UserDetailController._sharedInstance();
  factory UserDetailController() => _shared;

  Future<void> create({required String id, required String name}) async {
    await userDetails.doc(id).set({
      userDetailNameField: name,
    });
  }

  Future<UserDetails> get({required String id}) async {
    final querySnapshot = await userDetails
        .where(FieldPath.documentId, isEqualTo: id)
        .limit(1)
        .get();
    return querySnapshot.docs.map((doc) => UserDetails.fromSnapshot(doc)).first;
  }
}
