part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

@MappableClass()
class HomeState with HomeStateMappable{
  final HomeStatus status;
  final String? savedPath;
  final String? errorMessage;
  final List<String> savedFolders;

  const HomeState({
    this.status = HomeStatus.initial,
    this.savedPath,
    this.errorMessage,
    this.savedFolders = const [],
  });
}
