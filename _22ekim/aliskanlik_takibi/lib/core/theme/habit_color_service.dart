import 'package:flutter/material.dart';

import '../../data/models/habit.dart';

/// Alışkanlıklar için soft/pastel renk atama, çakışma önleme ve dönüştürme servisi.
class HabitColorService {
  HabitColorService._();

  /// Göz yormayan, ayırt edici, soft ve pastel renk paleti.
  static const List<Color> palette = [
    Color(0xFF3B6E52), // Adaçayı Yeşili
    Color(0xFF4A7298), // Soft Deniz Mavisi
    Color(0xFF7C6DAF), // Soft Lavanta
    Color(0xFFD97757), // Sıcak Terrakotta
    Color(0xFFC8657B), // Soft Gül Pembesi
    Color(0xFFD49B35), // Bal Sarısı
    Color(0xFF3D8B8B), // Soft Turkuaz
    Color(0xFF6E7D88), // Kül Grisi
    Color(0xFF8B7355), // Sıcak Kum
    Color(0xFF5A7D65), // Zeytin Yeşili
    Color(0xFF9E6B8A), // Pastel Leylak
    Color(0xFFE28A6E), // Pastel Şeftali
    Color(0xFF4D859E), // Buz Mavisi
    Color(0xFF8A9A5B), // Yosun Yeşili
  ];

  /// Renklerin Türkçe etiketleri
  static const Map<int, String> colorNames = {
    0xFF3B6E52: 'Adaçayı',
    0xFF4A7298: 'Deniz Mavisi',
    0xFF7C6DAF: 'Lavanta',
    0xFFD97757: 'Terrakotta',
    0xFFC8657B: 'Gül Pembesi',
    0xFFD49B35: 'Bal Sarısı',
    0xFF3D8B8B: 'Turkuaz',
    0xFF6E7D88: 'Kül Grisi',
    0xFF8B7355: 'Sıcak Kum',
    0xFF5A7D65: 'Zeytin Yeşili',
    0xFF9E6B8A: 'Leylak',
    0xFFE28A6E: 'Şeftali',
    0xFF4D859E: 'Buz Mavisi',
    0xFF8A9A5B: 'Yosun Yeşili',
  };

  /// Renk için Türkçe isim döndürür
  static String getName(Color color) {
    final argb = color.toARGB32();
    return colorNames[argb] ?? 'Özel Soft Renk';
  }

  /// Color nesnesini 7 karakterli '#RRGGBB' biçimine çevirir
  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// '#RRGGBB', 'RRGGBB' veya '0xFF...' metnini Color nesnesine çevirir
  static Color fromHex(String hex, {Color fallback = const Color(0xFF3B6E52)}) {
    try {
      var clean = hex.trim().replaceAll('#', '');
      if (clean.startsWith('0x') || clean.startsWith('0X')) {
        clean = clean.substring(2);
      }
      if (clean.length == 6) {
        clean = 'FF$clean';
      }
      if (clean.length == 8) {
        final val = int.parse(clean, radix: 16);
        return Color(val);
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Mevcut alışkanlıkların renklerini inceleyerek henüz kullanılmamış
  /// ilk soft rengi önerir. Palet tükenmişse türetilmiş soft renk döndürür.
  static Color suggestNextColor(List<Habit> existingHabits) {
    final usedColorValues = existingHabits.map((h) => h.colorValue).toSet();

    for (final col in palette) {
      if (!usedColorValues.contains(col.toARGB32())) {
        return col;
      }
    }

    // Palet dolmuşsa indexe göre soft HSL renk türet
    final offset = existingHabits.length;
    final hue = (offset * 137.508) % 360.0; // Altın oran açısı
    final hsl = HSLColor.fromAHSL(1.0, hue, 0.45, 0.65);
    return hsl.toColor();
  }

  /// Aynı kullanıcıya ait görevlerdeki mükerrer renkleri kalıcı yeni soft renklerle giderir.
  static List<Habit> resolveColorCollisions(List<Habit> habits) {
    final usedValues = <int>{};
    final result = <Habit>[];

    for (final habit in habits) {
      var colorVal = habit.colorValue;
      if (usedValues.contains(colorVal)) {
        // Çakışma var, yeni bir renk bul
        Color replacement = palette.firstWhere(
          (c) => !usedValues.contains(c.toARGB32()),
          orElse: () {
            final hue = ((result.length + 1) * 137.5) % 360.0;
            return HSLColor.fromAHSL(1.0, hue, 0.45, 0.65).toColor();
          },
        );
        colorVal = replacement.toARGB32();
        result.add(habit.copyWith(colorValue: colorVal));
      } else {
        result.add(habit);
      }
      usedValues.add(colorVal);
    }

    return result;
  }
}
