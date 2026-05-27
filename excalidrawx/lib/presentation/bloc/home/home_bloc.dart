import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:excalidrawx/domain/entities/error/drawer_error.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import '../../../core/locator.dart';
import 'package:dart_mappable/dart_mappable.dart';


part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.mapper.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {

  HomeBloc() : super(const HomeState()) {
    on<OnCreateDrawer>(_onCreateDrawer);
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
}
