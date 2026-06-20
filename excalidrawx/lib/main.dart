import 'package:excalidrawx/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:macos_ui/macos_ui.dart';

import 'dart:io' show Platform;

import 'core/locator.dart';
import 'core/logger/logger_setup.dart';


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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      debugShowCheckedModeBanner: false,
      title: 'ExcalidrawX',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}