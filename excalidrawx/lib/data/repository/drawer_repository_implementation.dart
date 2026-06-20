import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger/logger_setup.dart';
import '../constants/shared_prefs_keys.dart';

class DrawerRepositoryImplementation implements DrawerRepository {

  final SecureBookmarks _secureBookmarks = SecureBookmarks();

  /// Creates a new .excalidraw file, writes [data] to it, and stores a
  /// security-scoped bookmark for later access.
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
      final (resolvedFile, bookmark) = await _resolveOrCreateBookmark(
        file,
        null,
      );
      await resolvedFile.writeAsBytes(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefsKeys.currentDrawerBookmark, bookmark);
      logger.i("File save as $path");
      return Right(path);
    } catch (e) {
      logger.e("Save file error $e");
      return Left(DrawerCreateFailure(
        'Erreur lors de la sauvegarde',
        underlying: e,
      ));
    }
  }

  /// Reads and parses the Excalidraw file at [filePath], returning its
  /// elements. Reuses a matching bookmark or creates a new one, accessing
  /// the resource inside a security-scoped block.
  @override
  Future<Either<DrawerOpenFailure, List<dynamic>>> readDrawer(
    String filePath,
  ) async {
    final rawResult = await _readFileContent(filePath);

    return rawResult.fold(Left.new, (content) {
      try {
        final scene = jsonDecode(content) as Map<String, dynamic>;
        final elements = scene['elements'] as List<dynamic>;
        logger.i("File parsed (bookmark): $filePath");
        return Right(elements);
      } catch (e) {
        logger.e("Parse file error $e");
        return Left(DrawerOpenFailure(
          "Le fichier est corrompu ou n'est pas un fichier Excalidraw valide",
          underlying: e,
        ));
      }
    });
  }

  /// Reads the raw content of the file at [filePath]. Reuses a matching
  /// bookmark or creates a new one, accessing the resource inside a
  /// security-scoped block.
  @override
  Future<Either<DrawerOpenFailure, String>> readDrawerRaw(String filePath) =>
      _readFileContent(filePath);

  /// Merges the provided [elementsJson] into the existing Excalidraw file at
  /// [filePath], then writes the updated scene back. Reuses a matching bookmark
  /// or creates a new one, accessing the resource inside a security-scoped block.
  @override
  Future<Either<DrawerSaveFailure, Unit>> saveDrawer(
    String filePath,
    String elementsJson,
  ) async {
    final rawResult = await _readFileContent(filePath);

    final String contentString;
    switch (rawResult) {
      case Left(value: final error):
        return Left(DrawerSaveFailure(
          error.message,
          underlying: error.underlying,
        ));
      case Right(value: final content):
        contentString = content;
    }

    try {
      final scene = jsonDecode(contentString) as Map<String, dynamic>;
      final newElements = jsonDecode(elementsJson) as List<dynamic>;
      scene['elements'] = newElements;
      final encodedScene = jsonEncode(scene);

      final prefs = await SharedPreferences.getInstance();
      final existingBookmark = prefs.getString(SharedPrefsKeys.currentDrawerBookmark);
      final file = File(filePath).absolute;

      final (resolvedFile, bookmark) = await _resolveOrCreateBookmark(
        file,
        existingBookmark,
      );
      await prefs.setString(SharedPrefsKeys.currentDrawerBookmark, bookmark);

      await _secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
      try {
        await resolvedFile.writeAsString(encodedScene);
        logger.i("File saved (bookmark): ${resolvedFile.path}");
      } finally {
        await _secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
      return Right(unit);
    } catch (e) {
      logger.e("Save file error $e");
      return Left(DrawerSaveFailure(
        'Erreur lors de la sauvegarde du fichier',
        underlying: e,
      ));
    }
  }

  /// Returns the path of the stored bookmark, or null if none exists or the
  /// bookmark is stale.
  @override
  Future<Either<DrawerOpenFailure, String?>> getCurrentDrawerPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmark = prefs.getString(SharedPrefsKeys.currentDrawerBookmark);
      if (bookmark == null) {
        logger.i("No bookmark found in SharedPreferences");
        return const Right(null);
      }

      logger.i("Bookmark from prefs: ${bookmark.substring(0, bookmark.length.clamp(0, 30))}...");
      final file = await _secureBookmarks.resolveBookmark(bookmark) as File;
      logger.i("Resolved bookmark to path: ${file.path}");
      return Right(file.path);
    } catch (e) {
      logger.e("Restore drawer bookmark error $e");
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPrefsKeys.currentDrawerBookmark);
      logger.i("Removed stale bookmark from SharedPreferences");
      return const Right(null);
    }
  }

  /// Reads the raw string content of the file at [filePath], handling
  /// security-scoped bookmarks and I/O errors.
  Future<Either<DrawerOpenFailure, String>> _readFileContent(
    String filePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingBookmark = prefs.getString(SharedPrefsKeys.currentDrawerBookmark);
      final file = File(filePath).absolute;

      final (resolvedFile, bookmark) = await _resolveOrCreateBookmark(
        file,
        existingBookmark,
      );
      await prefs.setString(SharedPrefsKeys.currentDrawerBookmark, bookmark);

      await _secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
      try {
        final content = await resolvedFile.readAsString();
        logger.i("File read (bookmark): ${resolvedFile.path}");
        return Right(content);
      } finally {
        await _secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
      }
    } catch (e) {
      logger.e("Read file error $e");
      return Left(DrawerOpenFailure(
        'Erreur lors de la lecture du fichier',
        underlying: e,
      ));
    }
  }

  /// Resolves [bookmark] if it matches [file]; otherwise creates and resolves
  /// a new bookmark so the native plugin caches the resolved URL.
  Future<(File file, String bookmark)> _resolveOrCreateBookmark(
    File file,
    String? bookmark,
  ) async {
    if (bookmark != null) {
      try {
        final resolved = await _secureBookmarks.resolveBookmark(bookmark) as File;
        if (resolved.absolute.path == file.absolute.path) {
          return (resolved, bookmark);
        }
        logger.i(
          "Bookmark resolved to a different path "
          "(${resolved.absolute.path} != ${file.absolute.path}), creating a new one.",
        );
      } catch (e) {
        logger.w("Failed to resolve existing bookmark, creating a new one: $e");
      }
    }

    final newBookmark = await _secureBookmarks.bookmark(file);
    final resolved = await _secureBookmarks.resolveBookmark(newBookmark) as File;
    return (resolved, newBookmark);
  }
}
