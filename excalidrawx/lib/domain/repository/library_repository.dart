import 'package:excalidrawx/domain/entities/error/library_error.dart';
import 'package:fpdart/fpdart.dart';

abstract class LibraryRepository {
  /// Returns the saved library URL, or null if none is saved.
  Future<Either<LibraryError, String?>> getLibraryUrl();

  /// Saves the library URL. Returns the URL on success.
  Future<Either<LibraryError, String>> saveLibraryUrl(String url);
}
