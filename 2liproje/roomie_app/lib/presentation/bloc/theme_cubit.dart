import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/hive_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  final HiveStorageService _storage;

  ThemeCubit({HiveStorageService? storage})
    : _storage = storage ?? HiveStorageService.instance,
      super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _storage.settingsBox.get(_themeKey) as String?;
    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    _storage.settingsBox.put(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
