import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:excalidrawx/domain/usecase/create_drawer_usecase.dart';
import '../../../core/locator.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.mapper.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CreateDrawerUseCase _createDrawerUseCase = getIt.get<CreateDrawerUseCase>();

  HomeBloc() : super(const HomeState()) {
    on<OnCreateDrawer>(_onCreateDrawer);
  }

  Future<void> _onCreateDrawer(OnCreateDrawer event, Emitter<HomeState> emit) async {

  }
}
