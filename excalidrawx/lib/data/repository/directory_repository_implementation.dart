import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger/logger_setup.dart';

class DirectoryRepositoryImplementation implements DirectoryRepository {

  static const String _foldersKey = 'saved_folders';

  @override
  Future<Either<FolderCreateFailure, String>> createFolder(String name, {Directory? base}) async {

    try{
      final root = base ?? await getApplicationDocumentsDirectory();
      final dir = Directory('${root.path}/$name');
      logger.i("Create folder success on ${dir.path}");
      await dir.create(recursive: true);
      return Right(dir.path);
    }
    catch (e) {
      logger.e("create folder error $e");
      return Left(FolderCreateFailure(
      'Erreur lors de la création du dossier',
      ));
    }
  }

  @override
  Future<Either<FolderSelectFailure, String>> selectFolder({Directory? base}) async {
    try {
      final selectedPath = await FilePicker.getDirectoryPath(
        dialogTitle: 'Sélectionner un dossier',
      );

      if (selectedPath == null) {
        return Left(FolderSelectFailure('Aucun dossier sélectionné'));
      }

      final prefs = await SharedPreferences.getInstance();
      final existingPaths = prefs.getStringList(_foldersKey) ?? [];
      if (!existingPaths.contains(selectedPath)) {
        existingPaths.add(selectedPath);
        await prefs.setStringList(_foldersKey, existingPaths);
      }
      logger.i("Folder selected and saved: $selectedPath");

      return Right(selectedPath);
    } catch (e) {
      logger.e("select folder error $e");
      return Left(FolderSelectFailure('Erreur lors de la sélection du dossier'));
    }
  }

  @override
  Future<Either<FolderGetExistFailure, List<String>>> getFoldersExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = prefs.getStringList(_foldersKey) ?? [];
      final existingPaths = paths.where((p) => Directory(p).existsSync()).toList();
      logger.i("Folders found: $existingPaths");
      return Right(existingPaths);
    } catch (e) {
      logger.e("get folders exists error $e");
      return Left(FolderGetExistFailure('Erreur lors de la récupération des dossiers'));
    }
  }
}
