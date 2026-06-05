import 'dart:io';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:fpdart/fpdart.dart';

class OpenDrawerUseCase {
  Future<Either<DrawerOpenFailure, String>> call(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      return Right(content);
    } catch (e) {
      return Left(DrawerOpenFailure(
        'Erreur lors de la lecture du fichier',
        underlying: e,
      ));
    }
  }
}