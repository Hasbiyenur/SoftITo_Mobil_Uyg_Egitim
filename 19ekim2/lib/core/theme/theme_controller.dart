import 'package:flutter/material.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void dispose() {
    themeMode.dispose();
  }
}
