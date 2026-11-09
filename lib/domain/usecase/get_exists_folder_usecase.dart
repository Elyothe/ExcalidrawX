import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetExistsFolderUsecase {
  final DirectoryRepository _directoryRepository;

  GetExistsFolderUsecase({
    required this._directoryRepository,
  });

  Future<Either<FolderGetExistFailure, List<String>>> call() {
    return _directoryRepository.getFoldersExists();
  }
}
