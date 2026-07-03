import 'package:excalidrawx/domain/entities/error/library_error.dart';
import 'package:excalidrawx/domain/repository/library_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/logger/logger_setup.dart';
import '../constants/shared_prefs_keys.dart';

class LibraryRepositoryImplementation implements LibraryRepository {
  @override
  Future<Either<LibraryError, String?>> getLibraryUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(SharedPrefsKeys.libraryUrl);
      return Right(url);
    } catch (e) {
      logger.e("get library url error $e");
      return Left(LibraryFolderAccessFailure(
        'Erreur lors de la récupération de l\'URL de library',
        underlying: e,
      ));
    }
  }

  @override
  Future<Either<LibraryError, String>> saveLibraryUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefsKeys.libraryUrl, url);
      logger.i("Library URL saved: $url");
      return Right(url);
    } catch (e) {
      logger.e("save library url error $e");
      return Left(LibraryFolderAccessFailure(
        'Erreur lors de l\'enregistrement de l\'URL de library',
        underlying: e,
      ));
    }
  }
}
