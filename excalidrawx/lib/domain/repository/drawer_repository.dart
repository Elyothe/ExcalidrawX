import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class DrawerRepository {
  Future<Either<DrawerError, String>> createDrawer(
    Uint8List data, {
    required String name,
  });

  //Future<Either<DrawerOpenFailure, String>> openDrawer(String data);

  Future<Either<DrawerOpenFailure, String>> readDrawer(String filePath);

  Future<Either<DrawerSaveFailure, Unit>> saveDrawer(
    String filePath,
    String content,
  );

  Future<Either<DrawerOpenFailure, String?>> getCurrentDrawerPath();
}
