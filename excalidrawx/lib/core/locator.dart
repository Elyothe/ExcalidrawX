import 'package:excalidrawx/data/repository/drawer_repository_implementation.dart';
import 'package:excalidrawx/domain/repository/drawer_repository.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import 'package:get_it/get_it.dart';

class Locator {
  final getIt = GetIt.instance;

  void configureDependencies() {

    //Repository
    getIt.registerLazySingleton<DrawerRepository>(
      () => DrawerRepositoryImplementation(),
    );

    //Usecases
    getIt.registerLazySingleton<CreateDrawerUseCase>(
      () => CreateDrawerUseCase(getIt<DrawerRepository>()),
    );
  }
}