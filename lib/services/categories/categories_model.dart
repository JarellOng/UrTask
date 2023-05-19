import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:urtask/services/categories/categories_constants.dart';

@immutable
class Categories {
  final String id;
  final String colorId;
  final String name;

  const Categories({
    required this.id,
    required this.colorId,
    required this.name,
  });

  Categories.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        colorId = snapshot.data()[categoriesColorIdField],
        name = snapshot.data()[categoriesNameField];
}
