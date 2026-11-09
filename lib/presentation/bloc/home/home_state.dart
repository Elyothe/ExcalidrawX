part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

@MappableClass()
class HomeState with HomeStateMappable {
  final HomeStatus status;
  final String? savedPath;
  final String? errorMessage;
  final List<String> savedFolders;
  final Map<String, List<String>> folderFiles;
  final String? openedFilePath;
  final List<dynamic>? openedElements;

  const HomeState({
    this.status = HomeStatus.initial,
    this.savedPath,
    this.errorMessage,
    this.savedFolders = const [],
    this.folderFiles = const {},
    this.openedFilePath,
    this.openedElements,
  });
}
