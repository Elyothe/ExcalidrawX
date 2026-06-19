import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class DirectoryRepository {
  Future<Either<FolderCreateFailure, String>> createFolder(String name, {Directory? base});

  Future<Either<FolderDeleteFailure, String>> deleteFolder(String path);

  Future<Either<FolderSelectFailure, String>> selectFolder({Directory? base});

  Future<Either<FolderGetExistFailure, List<String>>> getFoldersExists();

  Future<Either<FolderGetExistFailure, List<String>>> listExcalidrawFiles(String path);
}
