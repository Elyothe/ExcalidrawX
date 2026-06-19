import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetListExcalidrawFilesUseCase {
  final DirectoryRepository _directoryRepository;

  GetListExcalidrawFilesUseCase({
    required this._directoryRepository,
  });

  Future<Either<FolderGetExistFailure, List<String>>> call(String path) {
    return _directoryRepository.listExcalidrawFiles(path);
  }
}
