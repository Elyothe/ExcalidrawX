part of 'excalidraw_bloc.dart';

abstract class ExcalidrawEvent {}

class OnOpenFile extends ExcalidrawEvent {
  final String filePath;
  final List<dynamic>? elements;

  OnOpenFile(this.filePath, {this.elements});
}

class OnInit extends ExcalidrawEvent {}

class OnSaveFile extends ExcalidrawEvent {
  final Object content;

  OnSaveFile(this.content);
}