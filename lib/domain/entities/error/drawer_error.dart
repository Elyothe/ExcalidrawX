sealed class DrawerError {}

final class DrawerSaveFailure extends DrawerError {
  final String message;
  final Object? underlying;
  DrawerSaveFailure(this.message, {this.underlying});
}

final class DrawerCreateFailure extends DrawerError {
  final String message;
  final Object? underlying;
  DrawerCreateFailure(this.message, {this.underlying});
}

final class DrawerOpenFailure extends DrawerError {
  final String message;
  final Object? underlying;
  DrawerOpenFailure(this.message, {this.underlying});
}

final class DrawerCancellation extends DrawerError {}