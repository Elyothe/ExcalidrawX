import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/entities/error/library_error.dart';
import 'package:excalidrawx/domain/repository/library_repository.dart';
import 'package:excalidrawx/domain/usecase/create_directory_usecase.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/get_exists_folder_usecase.dart';
import 'package:excalidrawx/domain/usecase/get_list_excalidraw_files_usecase.dart';
import 'package:excalidrawx/domain/usecase/open_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/select_folder_usecase.dart';
import '../../../core/locator.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/logger/logger_setup.dart';
import 'package:excalidrawx/domain/usecase/delete_folder_usecase.dart';


part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.mapper.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(const HomeState()) {
    on<OnCreateDrawer>(_onCreateDrawer);
    on<OnCreateFolder>(_onCreateFolder);
    on<OnSelectFolder>(_onSelectFolder);
    on<OnLoadSavedFolders>(_onLoadSavedFolders);
    on<OnDeleteFolder>(_onDeleteFolder);
    on<OnOpenDrawerFile>(_onOpenDrawerFile);
    on<OnImportLibrary>(_onImportLibrary);
    on<OnRestoreLibrary>(_onRestoreLibrary);
  }

  Future<void> _onCreateDrawer(OnCreateDrawer event, Emitter<HomeState> emit) async {

    emit(state.copyWith(status: HomeStatus.loading));

    final createDrawerUseCase = getIt.get<CreateDrawerUseCase>();
    final result = await createDrawerUseCase.call(event.data, name: event.name);

    result.fold(
      (error) => switch (error) {
        DrawerCancellation _ => emit(state.copyWith(
            status: HomeStatus.initial,
          )),
        DrawerCreateFailure(:final message) => emit(state.copyWith(
            status: HomeStatus.failure,
            errorMessage: message,
          )),
        _ => emit(state.copyWith(
            status: HomeStatus.failure,
            errorMessage: 'Une erreur est survenue',
          )),
      },
      (path) => emit(state.copyWith(
        status: HomeStatus.success,
        savedPath: path,
      )),
    );
  }

  Future<void> _onCreateFolder(
      OnCreateFolder event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final createDirectoryUseCase = getIt.get<CreateDirectoryUsecase>();

    final result = await createDirectoryUseCase(
      name: event.name,
      base: event.base,
    );

    result.fold(
          (error) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.message,
        ),
      ),
          (path) => emit(
        state.copyWith(
          status: HomeStatus.success,
          savedPath: path,
        ),
      ),
    );
  }

  Future<void> _onSelectFolder(
      OnSelectFolder event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final selectFolderUsecase = getIt.get<SelectFolderUsecase>();

    final result = await selectFolderUsecase();

    result.fold(
      (error) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.message,
        ),
      ),
      (path) {
        emit(state.copyWith(
          status: HomeStatus.success,
          savedPath: path,
        ));
        add(OnLoadSavedFolders());
      },
    );
  }

  Future<void> _onDeleteFolder(
      OnDeleteFolder event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final deleteFolderUsecase = getIt.get<DeleteFolderUsecase>();
    final result = await deleteFolderUsecase(event.path);

    result.fold(
      (error) => emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: error.message,
      )),
      (_) {
        logger.i("Folder removed from prefs: ${event.path}");
        add(OnLoadSavedFolders());
      },
    );
  }

  Future<void> _onLoadSavedFolders(
      OnLoadSavedFolders event,
      Emitter<HomeState> emit,
      ) async {
    final getExistsFolderUsecase = getIt.get<GetExistsFolderUsecase>();
    final getListExcalidrawFilesUseCase = getIt.get<GetListExcalidrawFilesUseCase>();

    final result = await getExistsFolderUsecase();

    await result.fold(
      (error) async => logger.e("Failed to load saved folders: ${error.message}"),
      (folders) async {
        logger.i("Saved folders loaded: $folders");
        final folderFiles = <String, List<String>>{};

        for (final folder in folders) {
          final filesResult = await getListExcalidrawFilesUseCase(folder);
          filesResult.fold(
            (error) => logger.e("Failed to list files for $folder: ${error.message}"),
            (files) => folderFiles[folder] = files,
          );
        }

        emit(state.copyWith(
          savedFolders: folders,
          folderFiles: folderFiles,
        ));
      },
    );
  }

  Future<void> _onOpenDrawerFile(
      OnOpenDrawerFile event,
      Emitter<HomeState> emit,
      ) async {
    final openDrawerUseCase = getIt.get<OpenDrawerUseCase>();
    final result = await openDrawerUseCase(event.filePath);

    result.fold(
      (error) {
        logger.e("Failed to open drawer ${event.filePath}: ${error.message}");
        emit(state.copyWith(
          openedFilePath: event.filePath,
          openedElements: null,
        ));
      },
      (elements) {
        logger.i("Drawer opened from sidebar: ${event.filePath}");
        emit(state.copyWith(
          openedFilePath: event.filePath,
          openedElements: elements,
        ));
      },
    );
  }

  Future<void> _onImportLibrary(
      OnImportLibrary event,
      Emitter<HomeState> emit,
  ) async {
    final url = event.url.trim();
    if (url.isEmpty) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: "L'URL de la library ne peut pas être vide",
      ));
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: "URL invalide. L'URL doit commencer par http:// ou https://",
      ));
      return;
    }

    // Extract library URL from #addLibrary hash if present
    var finalUrl = url;
    if (url.contains('#addLibrary=')) {
      final hashPart = url.split('#addLibrary=').last;
      final params = hashPart.split('&');
      var libUrl = Uri.decodeComponent(params.first);

      // Look for token parameter
      String? token;
      for (final param in params.skip(1)) {
        if (param.startsWith('token=')) {
          token = Uri.decodeComponent(param.substring(6));
          break;
        }
      }

      // Append token to library URL if found
      if (token != null && !libUrl.contains('token=')) {
        final separator = libUrl.contains('?') ? '&' : '?';
        libUrl = '$libUrl${separator}token=$token';
      }

      finalUrl = libUrl;
      logger.i('Extracted library URL from hash: $finalUrl');
    }

    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final repo = getIt.get<LibraryRepository>();
      final saveResult = await repo.saveLibraryUrl(finalUrl);

      saveResult.fold(
        (error) => emit(state.copyWith(
          status: HomeStatus.failure,
          errorMessage: switch (error) {
            LibraryFolderAccessFailure(:final message) => message,
            _ => "Erreur inconnue",
          },
        )),
        (savedUrl) {
          logger.i("Library URL saved: $savedUrl");
          emit(state.copyWith(
            status: HomeStatus.success,
            libraryUrl: finalUrl,
          ));
        },
      );
    } catch (e) {
      logger.e("Library URL save error: $e");
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: "Erreur lors de l'enregistrement de l'URL",
      ));
    }
  }

  Future<void> _onRestoreLibrary(
      OnRestoreLibrary event,
      Emitter<HomeState> emit,
  ) async {
    try {
      final repo = getIt.get<LibraryRepository>();
      final result = await repo.getLibraryUrl();

      result.fold(
        (error) => logger.e("Failed to restore library URL: ${switch (error) {
          LibraryFolderAccessFailure(:final message) => message,
          _ => "Unknown error",
        }}"),
        (url) {
          if (url != null && url.isNotEmpty) {
            logger.i("Library URL restored: $url");
            emit(state.copyWith(libraryUrl: url));
          }
        },
      );
    } catch (e) {
      logger.e("Restore library URL error: $e");
    }
  }
}
