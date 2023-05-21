class IdHelper {
  static int idToInt({required String id}) {
    final buffer = StringBuffer();
    buffer.write(id.replaceFirst('color', ''));
    return int.parse(buffer.toString());
  }
}
