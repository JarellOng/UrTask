import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urtask/service/colors/colors_model.dart';

class ColorController {
  final colors = FirebaseFirestore.instance.collection("colors");

  static final ColorController _shared = ColorController._sharedInstance();
  ColorController._sharedInstance();
  factory ColorController() => _shared;

  Future<Colors> get({required String id}) async {
    final querySnapshot =
        await colors.where(FieldPath.documentId, isEqualTo: id).get();
    return querySnapshot.docs.map((doc) => Colors.fromSnapshot(doc)).first;
  }

  Future<Iterable<Colors>> getAll() async {
    final querySnapshot = await colors.get();
    final colorList = querySnapshot.docs
        .map(
          (doc) => Colors.fromSnapshot(doc),
        )
        .toList();
    colorList.sort((a, b) {
      final id1 = _idToInt(id: a.id);
      final id2 = _idToInt(id: b.id);
      return id1.compareTo(id2);
    });
    return colorList;
  }

  static int _idToInt({required String id}) {
    final buffer = StringBuffer();
    buffer.write(id.replaceFirst('color', ''));
    return int.parse(buffer.toString());
  }
}
