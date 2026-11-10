import 'package:excalidrawx/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:macos_ui/macos_ui.dart';

import 'dart:io' show Platform;

import 'core/locator.dart';
import 'core/logger/logger_setup.dart';
import 'core/theme/app_theme.dart';
import 'core/web_server/local_excalidraw_server.dart';

GetIt getIt = GetIt.instance;
void setupLocator() {
  Locator.setup();
}

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );
  await config.apply();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogger(directory: '${Platform.environment['HOME']}/Documents');
  await _configureMacosWindowUtils();
  setupLocator();
  final serverResult = await LocalExcalidrawServer().start();
  final excalidrawUrl = serverResult.match(
    (error) =>
        throw StateError('Unable to start the local Excalidraw server: $error'),
    (url) => url,
  );

  runApp(MyApp(excalidrawUrl: excalidrawUrl));
}

class MyApp extends StatelessWidget {
  final Uri excalidrawUrl;

  const MyApp({super.key, required this.excalidrawUrl});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      debugShowCheckedModeBanner: false,
      title: 'ExcalidrawX',
      theme: AppTheme.macosDark,
      darkTheme: AppTheme.macosDark,
      themeMode: ThemeMode.dark,
      home: HomeScreen(excalidrawUrl: excalidrawUrl),
    );
  }
}
