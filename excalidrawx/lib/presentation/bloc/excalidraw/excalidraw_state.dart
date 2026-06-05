part of 'excalidraw_bloc.dart';

enum ExcalidrawStatus { initial, loading, success, failure }

@MappableClass()
class ExcalidrawState with ExcalidrawStateMappable {
  final ExcalidrawStatus status;
  final String? errorMessage;
  final List<dynamic>? elements;

  const ExcalidrawState({
    this.status = ExcalidrawStatus.initial,
    this.errorMessage,
    this.elements,
  });
}
