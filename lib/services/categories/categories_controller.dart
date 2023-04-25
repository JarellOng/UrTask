import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/services/categories/categories_constants.dart';
import 'package:urtask/services/categories/categories_model.dart';

class CategoryController {
  final categories = FirebaseFirestore.instance.collection("categories");

  static final CategoryController _shared =
      CategoryController._sharedInstance();
  CategoryController._sharedInstance();
  factory CategoryController() => _shared;

  Future<void> create({
    required String userId,
    required String colorId,
    required String name,
  }) async {
    await categories.add({
      categoriesUserIdField: userId,
      categoriesColorIdField: colorId,
      categoriesNameField: name
    });
  }

  Future<Categories> get({required String id}) async {
    final querySnapshot =
        await categories.where(FieldPath.documentId, isEqualTo: id).get();
    return querySnapshot.docs.map((doc) => Categories.fromSnapshot(doc)).first;
  }

  Stream<Iterable<Categories>> getAll({required String userId}) {
    return categories
        .where(
          categoriesUserIdField,
          whereIn: [userId, categoriesAdminUserId],
        )
        .orderBy(categoriesNameField)
        .snapshots()
        .map((data) => data.docs.map((doc) => Categories.fromSnapshot(doc)));
  }

  Future<void> update({
    required String id,
    required String colorId,
    required String name,
  }) async {
    await categories.doc(id).update({
      categoriesColorIdField: colorId,
      categoriesNameField: name,
    });
  }

  Future<void> delete({required String id}) async {
    await categories.doc(id).delete();
  }
}
