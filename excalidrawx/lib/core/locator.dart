import 'package:excalidrawx/data/repository/directory_repository_implementation.dart';
import 'package:excalidrawx/data/repository/drawer_repository_implementation.dart';
import 'package:excalidrawx/domain/repository/directory_repository.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:excalidrawx/domain/usecase/create_directory_usecase.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/delete_folder_usecase.dart';
import 'package:excalidrawx/domain/usecase/get_exists_folder_usecase.dart';
import 'package:excalidrawx/domain/usecase/open_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/select_folder_usecase.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class Locator {
  static void setup() {
    //Repository
    getIt.registerLazySingleton<DrawerRepository>(
          () => DrawerRepositoryImplementation(),
    );
    getIt.registerLazySingleton<DirectoryRepository>(
          () => DirectoryRepositoryImplementation(),
    );

    //Usecases
    getIt.registerLazySingleton(
            () => CreateDrawerUseCase(
          drawerRepository: getIt<DrawerRepository>(),
        )
    );
    getIt.registerLazySingleton(
            () => CreateDirectoryUsecase(
          directoryRepository: getIt<DirectoryRepository>(),
        )
    );
    getIt.registerLazySingleton(
            () => SelectFolderUsecase(
          directoryRepository: getIt<DirectoryRepository>(),
        )
    );
    getIt.registerLazySingleton(
            () => GetExistsFolderUsecase(
          directoryRepository: getIt<DirectoryRepository>(),
        )
    );
    getIt.registerLazySingleton(
            () => DeleteFolderUsecase(
          directoryRepository: getIt<DirectoryRepository>(),
        )
    );
    getIt.registerLazySingleton(
            () => OpenDrawerUseCase()
    );
  }
}