import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/usecase/create_directory_usecase.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/get_exists_folder_usecase.dart';
import 'package:excalidrawx/domain/usecase/select_folder_usecase.dart';
import '../../../core/locator.dart';
import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/logger/logger_setup.dart';
import '../../../domain/entities/error/directory_error.dart';


part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.mapper.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(const HomeState()) {
    on<OnCreateDrawer>(_onCreateDrawer);
    on<OnCreateFolder>(_onCreateFolder);
    on<OnSelectFolder>(_onSelectFolder);
    on<OnLoadSavedFolders>(_onLoadSavedFolders);
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
        DrawerSaveFailure(:final message) => emit(state.copyWith(
            status: HomeStatus.failure,
            errorMessage: message,
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
          (path) => emit(
        state.copyWith(
          status: HomeStatus.success,
          savedPath: path,
        ),
      ),
    );
  }

  Future<void> _onLoadSavedFolders(
      OnLoadSavedFolders event,
      Emitter<HomeState> emit,
      ) async {
    final getExistsFolderUsecase = getIt.get<GetExistsFolderUsecase>();

    final result = await getExistsFolderUsecase();

    result.fold(
      (error) => logger.e("Failed to load saved folders: ${error.message}"),
      (folders) {
        logger.i("Saved folders loaded: $folders");
        emit(state.copyWith(savedFolders: folders));
      },
    );
  }
}
