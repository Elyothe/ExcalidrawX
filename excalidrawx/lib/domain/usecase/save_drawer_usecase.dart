import 'dart:convert';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:fpdart/fpdart.dart';

class SaveDrawerUseCase {
  final DrawerRepository _drawerRepository;

  SaveDrawerUseCase({required DrawerRepository drawerRepository})
      : _drawerRepository = drawerRepository;

  Future<Either<DrawerSaveFailure, Unit>> call(
    String filePath,
    List<dynamic> newElements,
  ) async {
    final readResult = await _drawerRepository.readDrawer(filePath);

    switch (readResult) {
      case Left(value: final error):
        return Left(DrawerSaveFailure(
          error.message,
          underlying: error.underlying,
        ));
      case Right(value: final fileContent):
        final scene = jsonDecode(fileContent) as Map<String, dynamic>;
        scene['elements'] = newElements;
        return _drawerRepository.saveDrawer(filePath, jsonEncode(scene));
    }
  }
}
