import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';

class SelectFolderUsecase {
  final DirectoryRepository _directoryRepository;

  SelectFolderUsecase({
    required this._directoryRepository,
  });

  Future<Either<FolderSelectFailure, String>> call() {
    return _directoryRepository.selectFolder();
  }
}
