import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:urtask/services/calendars/calendars_controller.dart';
import 'package:urtask/services/categories/categories_constants.dart';
import 'package:urtask/services/categories/categories_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class CategoryController {
  final calendarController = CalendarController();
  final calendars = FirebaseFirestore.instance.collection("calendar");
  Future<CollectionReference<Map<String, dynamic>>> _getCollection() async {
    final calendar = await calendarController.get();
    return calendars.doc(calendar!.id).collection(categoriesCollectionId);
  }

  Future<CollectionReference<Map<String, dynamic>>>
      _getPresetCollection() async {
    final calendar = await calendarController.getPreset();
    return calendars.doc(calendar.id).collection(categoriesCollectionId);
  }

  static final CategoryController _shared =
      CategoryController._sharedInstance();
  CategoryController._sharedInstance();
  factory CategoryController() => _shared;

  Future<void> create({
    required String colorId,
    required String name,
  }) async {
    final categories = await _getCollection();
    await categories.add({
      categoriesColorIdField: colorId,
      categoriesNameField: name,
    });
  }

  Future<Categories> get({required String id}) async {
    final categories = await _getCollection();
    final querySnapshot = await categories
        .where(FieldPath.documentId, isEqualTo: id)
        .limit(1)
        .get();
    final category = querySnapshot.docs
        .map((doc) => Categories.fromSnapshot(doc))
        .firstOrNull;
    if (category != null) {
      return category;
    } else {
      final presetCategories = await _getPresetCollection();
      final presetquerySnapshot = await presetCategories
          .where(FieldPath.documentId, isEqualTo: id)
          .limit(1)
          .get();
      return presetquerySnapshot.docs
          .map((doc) => Categories.fromSnapshot(doc))
          .first;
    }
  }

  Stream<Iterable<Categories>> getAll() async* {
    final categories = await _getCollection();
    final presetCategories = await _getPresetCollection();
    final presetCategoryStream = presetCategories
        .snapshots()
        .map((data) => data.docs.map((doc) => Categories.fromSnapshot(doc)));
    yield* categories
        .snapshots()
        .map((data) => data.docs.map((doc) => Categories.fromSnapshot(doc)))
        .withLatestFrom(
          presetCategoryStream,
          (t, s) =>
              (t.toList() + s.toList()).sortedBy((element) => element.name),
        );
  }

  Future<void> update({
    required String id,
    required String colorId,
    required String name,
  }) async {
    final categories = await _getCollection();
    await categories.doc(id).update({
      categoriesColorIdField: colorId,
      categoriesNameField: name,
    });
  }

  Future<void> delete({required String id}) async {
    final categories = await _getCollection();
    await categories.doc(id).delete();
  }
}
