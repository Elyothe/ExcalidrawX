import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:fpdart/fpdart.dart';

class SaveDrawerUseCase {
  final DrawerRepository _drawerRepository;

  SaveDrawerUseCase({required DrawerRepository drawerRepository})
      : _drawerRepository = drawerRepository;

  Future<Either<DrawerSaveFailure, Unit>> call(
    String filePath,
    String elementsJson,
  ) =>
      _drawerRepository.saveDrawer(filePath, elementsJson);
}
