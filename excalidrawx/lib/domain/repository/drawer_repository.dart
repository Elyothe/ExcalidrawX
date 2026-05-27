import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class DrawerRepository {
  Future<Either<DrawerError, String>> saveFile(
    Uint8List data, {
    required String name,
  });
}
