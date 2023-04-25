import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/services/colors/colors_constants.dart';

@immutable
class Colors {
  final String id;
  final String name;
  final String hex;

  const Colors({required this.id, required this.name, required this.hex});

  Colors.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        name = snapshot.data()[colorNameField],
        hex = snapshot.data()[colorHexField];
}
