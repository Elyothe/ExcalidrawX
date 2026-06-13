part of 'excalidraw_bloc.dart';

abstract class ExcalidrawEvent {}

class OnOpenFile extends ExcalidrawEvent {
  final String filePath;

  OnOpenFile(this.filePath);
}

class OnSaveFile extends ExcalidrawEvent {
  final Object content;

  OnSaveFile(this.content);
}