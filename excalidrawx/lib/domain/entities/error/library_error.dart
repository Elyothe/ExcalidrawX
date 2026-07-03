sealed class LibraryError {}

final class LibraryImportFailure extends LibraryError {
  final String message;
  final Object? underlying;
  LibraryImportFailure(this.message, {this.underlying});
}

final class LibraryFolderAccessFailure extends LibraryError {
  final String message;
  final Object? underlying;
  LibraryFolderAccessFailure(this.message, {this.underlying});
}

final class LibraryParseFailure extends LibraryError {
  final String message;
  final Object? underlying;
  LibraryParseFailure(this.message, {this.underlying});
}
