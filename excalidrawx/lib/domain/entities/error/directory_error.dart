sealed class DirectoryError {}

final class FolderCreateFailure extends DirectoryError {
  final String message;
  FolderCreateFailure(this.message);
}

final class FolderSelectFailure extends DirectoryError {
  final String message;
  FolderSelectFailure(this.message);
}

final class FolderGetExistFailure extends DirectoryError {
  final String message;
  FolderGetExistFailure(this.message);
}