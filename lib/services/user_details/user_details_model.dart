import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/services/user_details/user_details_constants.dart';

@immutable
class UserDetails {
  final String id;
  final String name;

  const UserDetails({
    required this.id,
    required this.name,
  });

  UserDetails.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        name = snapshot.data()[userDetailNameField];
}
