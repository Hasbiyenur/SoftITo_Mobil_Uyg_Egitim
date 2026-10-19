import 'package:flutter/material.dart';

class AppTheme {
  // Dark Obsidian & Neon Renk Paleti
  static const Color background = Color(0xFF12131A);
  static const Color surface = Color(0xFF1A1C24);
  static const Color surfaceVariant = Color(0xFF222530);
  static const Color border = Color(0xFF2E3240);

  // Neon Vurgu Renkleri
  static const Color neonCyan = Color(0xFF00D2FF);
  static const Color neonAqua = Color(0xFF00F5D4);
  static const Color neonLime = Color(0xFF70E000);
  static const Color neonOrange = Color(0xFFFF9E00);
  static const Color neonRed = Color(0xFFFF4D4F);

  // Metin Renkleri
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A5B5);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonAqua,
        tertiary: neonLime,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: neonCyan,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
