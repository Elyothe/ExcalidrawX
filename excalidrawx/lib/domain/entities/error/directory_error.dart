sealed class DirectoryError {}

final class FolderCreateFailure extends DirectoryError {
  final String message;
  FolderCreateFailure(this.message);
}
