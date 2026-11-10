import 'package:fpdart/fpdart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:excalidrawx/core/logger/logger_setup.dart';
import 'scripts/remove_footer_right_ui_script.dart';
import 'scripts/remove_main_menu_script.dart';
import 'scripts/remove_top_right_ui_script.dart';

class ExcalidrawJsInjector {
  final WebViewController controller;

  const ExcalidrawJsInjector(this.controller);

  Future<Either<Object, Unit>> removeMainMenu() {
    return _runScript('remove-main-menu', RemoveMainMenuScript.source);
  }

  Future<Either<Object, Unit>> removeTopRightUi() {
    return _runScript('remove-top-right-ui', RemoveTopRightUiScript.source);
  }

  Future<Either<Object, Unit>> removeFooterRightUi() {
    return _runScript(
      'remove-footer-right-ui',
      RemoveFooterRightUiScript.source,
    );
  }

  Future<Either<Object, Unit>> _runScript(String name, String source) async {
    logger.i('Executing Excalidraw JS script: $name');
    try {
      await controller.runJavaScript(source);
      logger.i('Excalidraw JS script executed: $name');
      return right(unit);
    } catch (error) {
      logger.e('Excalidraw JS script failed: $name - $error');
      return left(error);
    }
  }
}
