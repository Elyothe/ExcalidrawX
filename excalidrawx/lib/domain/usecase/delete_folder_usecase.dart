import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteFolderUsecase {
  final DirectoryRepository _directoryRepository;

  DeleteFolderUsecase({
    required this._directoryRepository,
  });

  Future<Either<FolderDeleteFailure, String>> call(String path) {
    return _directoryRepository.deleteFolder(path);
  }
}
