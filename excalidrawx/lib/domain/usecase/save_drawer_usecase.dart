import 'dart:io';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:fpdart/fpdart.dart';

class SaveDrawerUseCase {
  Future<Either<DrawerSaveFailure, Unit>> call(
      String filePath, String content) async {
    try {
      await File(filePath).writeAsString(content);
      return Right(unit);
    } catch (e) {
      return Left(DrawerSaveFailure(
        'Erreur lors de la sauvegarde du fichier',
        underlying: e,
      ));
    }
  }
}
