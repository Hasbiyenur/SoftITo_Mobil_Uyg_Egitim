import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../data/models/app_settings.dart';

class SettingsController extends ChangeNotifier {
  final LocalStore store;

  ThemeMode _themeMode = ThemeMode.light;
  String? _currentUserId;

  SettingsController({required this.store});

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String? get currentUserId => _currentUserId;

  Future<void> initUser(String userId) async {
    _currentUserId = userId;
    final doc = await store.load();
    final settings = doc.appSettingsByUser[userId];
    if (settings != null) {
      _themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(String userId, ThemeMode mode) async {
    _themeMode = mode;
    _currentUserId = userId;
    notifyListeners();

    try {
      final doc = await store.load();
      final updatedMap = Map<String, AppSettings>.from(doc.appSettingsByUser);
      updatedMap[userId] = AppSettings(
        userId: userId,
        themeMode: mode == ThemeMode.dark ? 'dark' : 'light',
      );
      final updatedDoc = doc.copyWith(appSettingsByUser: updatedMap);
      await store.save(updatedDoc);
    } catch (_) {
      // Sessizce hatayı yakala
    }
  }

  void resetToLight() {
    _themeMode = ThemeMode.light;
    _currentUserId = null;
    notifyListeners();
  }
}
