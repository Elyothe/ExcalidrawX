part of 'home_bloc.dart';

abstract class HomeEvent {}

class OnCreateDrawer extends HomeEvent {
  final Uint8List data;
  final String name;

  OnCreateDrawer(this.data, {required this.name});
}

class OnCreateFolder extends HomeEvent {
  final String name;
  final Directory? base;

  OnCreateFolder(this.name, {this.base});
}

class OnSelectFolder extends HomeEvent {}

class OnLoadSavedFolders extends HomeEvent {}

class OnDeleteFolder extends HomeEvent {
  final String path;
  OnDeleteFolder(this.path);
}

class OnOpenDrawerFile extends HomeEvent {
  final String filePath;
  OnOpenDrawerFile(this.filePath);
}