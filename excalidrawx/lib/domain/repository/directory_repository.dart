import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class DirectoryRepository {
  Future<Either<FolderCreateFailure, String>> createFolder(String name, {Directory? base});

  Future<Either<FolderSelectFailure, String>> selectFolder({Directory? base});

  Future<Either<FolderGetExistFailure, List<String>>> getFoldersExists();
}
