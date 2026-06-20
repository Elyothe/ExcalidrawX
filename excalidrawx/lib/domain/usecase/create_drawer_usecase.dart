import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateDrawerUseCase {
  final DrawerRepository _drawerRepository;

  CreateDrawerUseCase({
    required this._drawerRepository,
  });

  Future<Either<DrawerError, String>> call(
    Uint8List data, {
    required String name,
  }) {
    return _drawerRepository.createDrawer(data, name: name);
  }
}
