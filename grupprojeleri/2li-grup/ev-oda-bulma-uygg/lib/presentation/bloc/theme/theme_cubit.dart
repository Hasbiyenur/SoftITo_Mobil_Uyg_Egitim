import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// Uygulama temasını (Açık / Koyu mod) yöneten ve kullanıcının tercihini Hive veritabanında saklayan Cubit sınıfı.
class ThemeCubit extends Cubit<ThemeMode> {
  /// Ayarların tutulduğu Hive kutusu adı
  static const String _boxName = 'settings_box';

  /// Tema tercihinin saklandığı anahtar
  static const String _key = 'theme_mode';

  /// Başlangıçta varsayılan olarak aydınlık temayı (ThemeMode.light) seçer ve kaydedilmiş tercihi yükler.
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Hive veritabanında önceden kaydedilmiş tema tercihini okur ve durumu günceller.
  void _loadTheme() {
    try {
      final box = Hive.box(_boxName);
      final saved = box.get(_key) as String?;
      if (saved == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    } catch (_) {
      emit(ThemeMode.light);
    }
  }

  /// Aktif temayı tersine çevirir (Açık ise Koyu, Koyu ise Açık) ve yeni tercihi kalıcı olarak kaydeder.
  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    try {
      final box = Hive.box(_boxName);
      box.put(_key, newMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}
