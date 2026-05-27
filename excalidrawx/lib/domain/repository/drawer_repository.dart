import 'dart:typed_data';

abstract class DrawerRepository {
  Future<String?> saveFile(Uint8List data, {required String name});
}
