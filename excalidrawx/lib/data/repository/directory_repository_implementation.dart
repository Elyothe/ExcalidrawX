import 'dart:convert';
import 'dart:io';

import 'package:excalidrawx/domain/entities/error/directory_error.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger/logger_setup.dart';
import '../constants/shared_prefs_keys.dart';

class DirectoryRepositoryImplementation implements DirectoryRepository {
  final SecureBookmarks _secureBookmarks = SecureBookmarks();

  /// Creates a new folder in the specified base directory or in the default
  /// application documents directory. If [base] is a previously saved folder,
  /// the stored security-scoped bookmark is activated during the operation.
  /// Returns the created folder path on success.
  @override
  Future<Either<FolderCreateFailure, String>> createFolder(
    String name, {
    Directory? base,
  }) async {
    try {
      if (base != null) {
        return await _withFolderAccess(
          base.absolute.path,
          (resolvedBase) async {
            final dir = Directory('${resolvedBase.path}/$name');
            await dir.create(recursive: true);
            logger.i("Create folder success on ${dir.path}");
            return Right(dir.path);
          },
        );
      }

      final root = await getApplicationDocumentsDirectory();
      final dir = Directory('${root.path}/$name');
      await dir.create(recursive: true);
      logger.i("Create folder success on ${dir.path}");
      return Right(dir.path);
    } catch (e) {
      logger.e("create folder error $e");
      return Left(FolderCreateFailure(
        'Erreur lors de la création du dossier',
      ));
    }
  }

  /// Removes the folder path from SharedPreferences and deletes the associated
  /// security-scoped bookmark if one exists.
  /// Returns the removed path on success.
  @override
  Future<Either<FolderDeleteFailure, String>> deleteFolder(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPaths = prefs.getStringList(SharedPrefsKeys.savedFolders) ?? [];
      existingPaths.remove(path);
      await prefs.setStringList(SharedPrefsKeys.savedFolders, existingPaths);

      final bookmarks = await _loadFolderBookmarks();
      if (bookmarks.remove(path) != null) {
        await _saveFolderBookmarks(bookmarks);
      }

      logger.i("Folder removed from prefs: $path");
      return Right(path);
    } catch (e) {
      logger.e("Delete folder error $e");
      return Left(FolderDeleteFailure(
        'Erreur lors de la suppression du dossier',
      ));
    }
  }

  /// Opens a native folder picker dialog for the user to select a directory.
  /// Saves the chosen path to SharedPreferences, creates and stores a
  /// security-scoped bookmark for it, then returns the path on success.
  @override
  Future<Either<FolderSelectFailure, String>> selectFolder({Directory? base}) async {
    try {
      final selectedPath = await FilePicker.getDirectoryPath(
        dialogTitle: 'Sélectionner un dossier',
      );

      if (selectedPath == null) {
        return Left(FolderSelectFailure('Aucun dossier sélectionné'));
      }

      final directory = Directory(selectedPath).absolute;
      final bookmark = await _secureBookmarks.bookmark(directory);

      final prefs = await SharedPreferences.getInstance();
      final existingPaths = prefs.getStringList(SharedPrefsKeys.savedFolders) ?? [];
      if (!existingPaths.contains(directory.path)) {
        existingPaths.add(directory.path);
        await prefs.setStringList(SharedPrefsKeys.savedFolders, existingPaths);
      }

      final bookmarks = await _loadFolderBookmarks();
      bookmarks[directory.path] = bookmark;
      await _saveFolderBookmarks(bookmarks);

      logger.i("Folder selected and saved: ${directory.path}");
      return Right(directory.path);
    } catch (e) {
      logger.e("select folder error $e");
      return Left(FolderSelectFailure('Erreur lors de la sélection du dossier'));
    }
  }

  /// Retrieves the list of previously saved folder paths from SharedPreferences,
  /// resolves their security-scoped bookmarks, and filters out those that no
  /// longer exist or have stale bookmarks.
  @override
  Future<Either<FolderGetExistFailure, List<String>>> getFoldersExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = prefs.getStringList(SharedPrefsKeys.savedFolders) ?? [];
      final bookmarks = await _loadFolderBookmarks();
      final existingPaths = <String>[];

      for (final path in paths) {
        final bookmark = bookmarks[path];
        if (bookmark == null) {
          if (Directory(path).existsSync()) {
            existingPaths.add(path);
          }
          continue;
        }

        try {
          final resolved = await _secureBookmarks.resolveBookmark(
            bookmark,
            isDirectory: true,
          ) as Directory;
          await _secureBookmarks.startAccessingSecurityScopedResource(resolved);
          try {
            if (await resolved.exists()) {
              existingPaths.add(path);
            }
          } finally {
            await _secureBookmarks.stopAccessingSecurityScopedResource(resolved);
          }
        } catch (e) {
          logger.w("Folder bookmark stale or invalid for $path: $e");
          bookmarks.remove(path);
        }
      }

      await _saveFolderBookmarks(bookmarks);
      logger.i("Folders found: $existingPaths");
      return Right(existingPaths);
    } catch (e) {
      logger.e("get folders exists error $e");
      return Left(FolderGetExistFailure(
        'Erreur lors de la récupération des dossiers',
      ));
    }
  }

  /// Lists all `.excalidraw` files in [path], activating the folder's
  /// security-scoped bookmark if one exists.
  @override
  Future<Either<FolderGetExistFailure, List<String>>> listExcalidrawFiles(
    String path,
  ) async {
    try {
      final files = await _withFolderAccess(
        path,
        (resolvedDir) async {
          final entities = await resolvedDir.list().toList();
          return entities
              .whereType<File>()
              .where((file) => file.path.toLowerCase().endsWith('.excalidraw'))
              .map((file) => file.path)
              .toList();
        },
      );

      logger.i("Excalidraw files found in $path: $files");
      return Right(files);
    } catch (e) {
      logger.e("list excalidraw files error $e");
      return Left(FolderGetExistFailure(
        'Erreur lors de la liste des fichiers',
      ));
    }
  }

  /// Loads the map of saved folder bookmarks from SharedPreferences.
  Future<Map<String, String>> _loadFolderBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SharedPrefsKeys.savedFolderBookmarks);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      logger.w("Failed to decode folder bookmarks: $e");
      return {};
    }
  }

  /// Saves the map of folder bookmarks to SharedPreferences.
  Future<void> _saveFolderBookmarks(Map<String, String> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SharedPrefsKeys.savedFolderBookmarks,
      jsonEncode(bookmarks),
    );
  }

  /// Executes [action] with the resolved directory for [path]. If a bookmark
  /// exists for [path], the security-scoped resource is started before the
  /// action and stopped afterwards. Otherwise, the original directory is used.
  Future<T> _withFolderAccess<T>(
    String path,
    Future<T> Function(Directory resolvedDir) action,
  ) async {
    final bookmarks = await _loadFolderBookmarks();
    final bookmark = bookmarks[path];

    if (bookmark == null) {
      return await action(Directory(path));
    }

    final resolved = await _secureBookmarks.resolveBookmark(
      bookmark,
      isDirectory: true,
    ) as Directory;
    await _secureBookmarks.startAccessingSecurityScopedResource(resolved);
    try {
      return await action(resolved);
    } finally {
      await _secureBookmarks.stopAccessingSecurityScopedResource(resolved);
    }
  }
}
