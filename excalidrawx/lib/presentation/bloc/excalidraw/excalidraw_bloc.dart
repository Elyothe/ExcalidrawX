import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:excalidrawx/core/locator.dart';
import 'package:excalidrawx/domain/usecase/open_drawer_usecase.dart';
import 'package:excalidrawx/domain/usecase/save_drawer_usecase.dart';

part 'excalidraw_event.dart';
part 'excalidraw_state.dart';
part 'excalidraw_bloc.mapper.dart';

class ExcalidrawBloc extends Bloc<ExcalidrawEvent, ExcalidrawState> {
  String? _currentFilePath;

  String? get currentFilePath => _currentFilePath;

  ExcalidrawBloc() : super(const ExcalidrawState()) {
    on<OnOpenFile>(_onOpenFile);
    on<OnSaveFile>(_onSaveFile);
  }

  Future<void> _onOpenFile(
      OnOpenFile event, Emitter<ExcalidrawState> emit) async {
    _currentFilePath = event.filePath;

    emit(state.copyWith(status: ExcalidrawStatus.loading));

    final openDrawerUseCase = getIt.get<OpenDrawerUseCase>();
    final result = await openDrawerUseCase(event.filePath);

    result.fold(
      (error) => emit(state.copyWith(
        status: ExcalidrawStatus.failure,
        errorMessage: error.message,
      )),

      (content) {
        try {
          final scene = jsonDecode(content) as Map<String, dynamic>;
          final elements = scene['elements'] as List<dynamic>;
          emit(state.copyWith(
            status: ExcalidrawStatus.success,
            elements: elements,
          ));
        } catch (e) {
          emit(state.copyWith(
            status: ExcalidrawStatus.failure,
            errorMessage: "Erreur lors de l'ouverture du fichier",
          ));
        }
      },
    );
  }

  Future<void> _onSaveFile(
      OnSaveFile event, Emitter<ExcalidrawState> emit) async {
    if (_currentFilePath == null) return;

    final saveDrawerUseCase = getIt.get<SaveDrawerUseCase>();
    final result = await saveDrawerUseCase(
      _currentFilePath!,
      jsonDecode(event.content.toString()) as List<dynamic>,
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
