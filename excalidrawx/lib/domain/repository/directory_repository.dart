import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class DirectoryRepository {
  Future<Either<DirectoryError, String>> createFolder(String name, {Directory? base});
}
