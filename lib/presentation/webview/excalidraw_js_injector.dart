import 'package:webview_flutter/webview_flutter.dart';

import 'scripts/remove_main_menu_script.dart';
import 'scripts/remove_top_right_ui_script.dart';

class ExcalidrawJsInjector {
  final WebViewController controller;

  const ExcalidrawJsInjector(this.controller);

  Future<void> removeMainMenu() {
    return controller.runJavaScript(RemoveMainMenuScript.source);
  }

  Future<void> removeTopRightUi() {
    return controller.runJavaScript(RemoveTopRightUiScript.source);
  }
}
