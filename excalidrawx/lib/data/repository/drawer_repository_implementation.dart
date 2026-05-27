import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

class DrawerRepositoryImplementation implements DrawerRepository {

  @override
  Future<Either<DrawerError, String>> saveFile(
    Uint8List data, {
    required String name,
  }) async {
    final fileName = name.endsWith('.excalidraw') ? name : '$name.excalidraw';

    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Enregistrer le fichier Excalidraw',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['excalidraw'],
      );

      if (path == null) return Left(DrawerCancellation());

      final file = File(path);
      await file.writeAsBytes(data);
      return Right(path);
    } catch (e) {
      return Left(DrawerSaveFailure(
        'Erreur lors de la sauvegarde',
        underlying: e,
      ));
    }
  }
}
