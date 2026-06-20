import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:excalidrawx/core/locator.dart';
import 'package:excalidrawx/domain/usecase/restore_current_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/open_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/save_drawer_usecase.dart';

part 'excalidraw_event.dart';
part 'excalidraw_state.dart';
part 'excalidraw_bloc.mapper.dart';

class ExcalidrawBloc extends Bloc<ExcalidrawEvent, ExcalidrawState> {
  String? _currentFilePath;

  String? get currentFilePath => _currentFilePath;

  ExcalidrawBloc() : super(const ExcalidrawState()) {
    on<OnInit>(_onInit);
    on<OnOpenFile>(_onOpenFile);
    on<OnSaveFile>(_onSaveFile);
    add(OnInit());
  }

  Future<void> _onInit(
      OnInit event, Emitter<ExcalidrawState> emit) async {
    final restoreUseCase = getIt.get<RestoreCurrentDrawerUseCase>();
    final result = await restoreUseCase();
    result.fold(
      (_) {},
      (path) {
        _currentFilePath = path;
        if (path != null) {
          add(OnOpenFile(path));
        }
      },
    );
  }

  Future<void> _onOpenFile(
      OnOpenFile event, Emitter<ExcalidrawState> emit) async {
    _currentFilePath = event.filePath;

    if (event.elements != null) {
      emit(state.copyWith(
        status: ExcalidrawStatus.success,
        elements: event.elements,
      ));
      return;
    }

    emit(state.copyWith(status: ExcalidrawStatus.loading));

    final openDrawerUseCase = getIt.get<OpenDrawerUseCase>();
    final result = await openDrawerUseCase(event.filePath);

    result.fold(
      (error) => emit(state.copyWith(
        status: ExcalidrawStatus.failure,
        errorMessage: error.message,
      )),
      (elements) => emit(state.copyWith(
        status: ExcalidrawStatus.success,
        elements: elements,
      )),
    );
  }

  Future<void> _onSaveFile(
      OnSaveFile event, Emitter<ExcalidrawState> emit) async {
    if (_currentFilePath == null) return;

    final saveDrawerUseCase = getIt.get<SaveDrawerUseCase>();
    final result = await saveDrawerUseCase(
      _currentFilePath!,
      event.content.toString(),
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ExcalidrawStatus.failure,
        errorMessage: error.message,
      )),
      (_) => emit(state.copyWith(status: ExcalidrawStatus.success)),
    );
  }
}
