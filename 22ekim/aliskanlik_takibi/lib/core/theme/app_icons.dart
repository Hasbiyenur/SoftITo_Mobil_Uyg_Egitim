import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static const List<IconData> availableIcons = [
    Icons.menu_book_rounded,
    Icons.water_drop_rounded,
    Icons.directions_walk_rounded,
    Icons.directions_run_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.self_improvement_rounded,
    Icons.bedtime_rounded,
    Icons.code_rounded,
    Icons.music_note_rounded,
    Icons.brush_rounded,
    Icons.restaurant_rounded,
    Icons.eco_rounded,
  ];

  /// Verilen codePoint değerine karşılık gelen sabit IconData nesnesini döner.
  static IconData fromCodePoint(int codePoint) {
    for (final icon in availableIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.eco_rounded;
  }
}
