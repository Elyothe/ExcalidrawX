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