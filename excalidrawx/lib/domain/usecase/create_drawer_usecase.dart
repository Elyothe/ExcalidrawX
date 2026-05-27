import 'dart:typed_data';

import 'package:excalidrawx/domain/repository/drawer_repository.dart';

class CreateDrawerUseCase {
  final DrawerRepository _repository;

  CreateDrawerUseCase(this._repository);

  Future<String?> call(Uint8List data, {required String name}) {
    return _repository.saveFile(data, name: name);
  }
}
