import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

abstract final class AppTheme {
  static const background = Color(0xFF0D0F12);
  static const surface = Color(0xFF171A1F);
  static const elevatedSurface = Color(0xFF222832);
  static const button = Color(0xFF2D3540);
  static const selected = Color(0xFF2563A6);
  static const accent = Color(0xFF4A9EFF);
  static const accentHover = Color(0xFF6CB3FF);
  static const text = Color(0xFFF2F4F7);
  static const secondaryText = Color(0xFFAAB4C0);
  static const disabledText = Color(0xFF687380);
  static const border = Color(0xFF303945);
  static const error = Color(0xFFE05D68);
  static const success = Color(0xFF62C18A);

  static final macosDark = MacosThemeData(
    brightness: Brightness.dark,
    primaryColor: accent,
    canvasColor: background,
    dividerColor: border,
    isMainWindow: true,
  );
}
