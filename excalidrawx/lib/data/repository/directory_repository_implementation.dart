import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logger/logger_setup.dart';

class DirectoryRepositoryImplementation implements DirectoryRepository {


  @override
  Future<Either<DirectoryError, String>> createFolder(String name, {Directory? base}) async {

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
}
