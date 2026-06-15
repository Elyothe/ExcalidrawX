import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:fpdart/fpdart.dart';

class OpenDrawerUseCase {
  final DrawerRepository _drawerRepository;

  OpenDrawerUseCase({required DrawerRepository drawerRepository})
      : _drawerRepository = drawerRepository;

  Future<Either<DrawerOpenFailure, List<dynamic>>> call(String filePath) =>
      _drawerRepository.readDrawer(filePath);
}
