import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:fpdart/fpdart.dart';

class RestoreCurrentDrawerUseCase {
  final DrawerRepository _drawerRepository;

  RestoreCurrentDrawerUseCase({required DrawerRepository drawerRepository})
      : _drawerRepository = drawerRepository;

  Future<Either<DrawerOpenFailure, String?>> call() =>
      _drawerRepository.getCurrentDrawerPath();
}
