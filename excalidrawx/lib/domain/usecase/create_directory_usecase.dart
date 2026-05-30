import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateDirectoryUsecase {
  final DirectoryRepository _directoryRepository;

  CreateDirectoryUsecase({
    required this._directoryRepository,
  });

  Future<Either<DirectoryError, String>> call({
    required String name,
    Directory? base,
  }) {
    return _directoryRepository.createFolder(name, base: base);
  }
}