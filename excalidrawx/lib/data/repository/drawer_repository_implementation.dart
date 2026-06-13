import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/logger/logger_setup.dart';

class DrawerRepositoryImplementation implements DrawerRepository {

  /// Opens a "Save As" dialog with [name] (adds `.excalidraw` if missing).
  /// Returns the saved file path, or `null` if the user cancelled.
  @override
  Future<Either<DrawerError, String>> createDrawer(
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
      logger.i("File save as $path");
      return Right(path);
    } catch (e) {
      logger.e("Save file error $e");
      return Left(DrawerSaveFailure(
        'Erreur lors de la sauvegarde',
        underlying: e,
      ));
    }
  }

  /// Opens a file picker to select an existing `.excalidraw` file.
  /// Returns the selected file path on success.
  @override
  Future<Either<DrawerOpenFailure, String>> openDrawer(
    Uint8List data, {
    required String name,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Ouvrir un fichier Excalidraw',
        type: FileType.custom,
        allowedExtensions: ['excalidraw'],
      );

      if (result == null) return Left(DrawerOpenFailure('Aucun fichier sélectionné'));

      final filePath = result.files.single.path!;
      logger.i("File opened: $filePath");
      return Right(filePath);
    } catch (e) {
      logger.e("Open file error $e");
      return Left(DrawerOpenFailure(
        'Erreur lors de l\'ouverture du fichier',
        underlying: e,
      ));
    }
  }
}
