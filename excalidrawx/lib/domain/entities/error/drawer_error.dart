sealed class DrawerError {}

final class DrawerSaveFailure extends DrawerError {
  final String message;
  final Object? underlying;
  DrawerSaveFailure(this.message, {this.underlying});
}

final class DrawerCancellation extends DrawerError {}