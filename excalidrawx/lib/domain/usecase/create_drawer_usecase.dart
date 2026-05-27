import 'dart:typed_data';

import 'package:excalidrawx/domain/repository/drawer_repository.dart';

class CreateDrawerUseCase {
  final DrawerRepository _drawerRepository;

  CreateDrawerUseCase({
    required DrawerRepository drawerRepository,
  }) : _drawerRepository = drawerRepository;

  Future<String?> call(Uint8List data, {required String name}) {
    return _drawerRepository.saveFile(data, name: name);
  }
}
