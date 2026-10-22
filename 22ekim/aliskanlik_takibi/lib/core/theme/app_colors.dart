import 'package:flutter/material.dart';

/// Uygulamanın soft, göz yormayan, pastel Material 3 renk paleti.
class AppColors {
  AppColors._();

  // Ana renkler
  static const Color primary = Color(0xFF3B6E52); // Soft orman / adaçayı yeşili
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFD6E8DC);
  static const Color onPrimaryContainer = Color(0xFF143322);

  static const Color secondary = Color(0xFF556F7A); // Soft arduvaz mavi/gri
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFD9E4E8);
  static const Color onSecondaryContainer = Color(0xFF192A32);

  // Arka plan ve kart yüzeyleri
  static const Color background = Color(0xFFF7F9F8);
  static const Color onBackground = Color(0xFF1F2933);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F2933);
  static const Color surfaceVariant = Color(0xFFEEF2F0);
  static const Color onSurfaceVariant = Color(0xFF52606D);

  // Durum ve uyarı renkleri (soft)
  static const Color success = Color(0xFF43936C);
  static const Color error = Color(0xFFD9534F);
  static const Color onError = Colors.white;
  static const Color warning = Color(0xFFE08A3C);
  static const Color info = Color(0xFF3E82AF);

  // Tamamlanmış öğeler
  static const Color completedSurface = Color(0xFFF1F5F2);
  static const Color completedText = Color(0xFF8A9BA8);
  static const Color completedBorder = Color(0xFFD2DCD5);

  // Çizgi ve ayraçlar
  static const Color outline = Color(0xFFDCE3DF);
  static const Color outlineVariant = Color(0xFFE8ECE9);

  // Alışkanlıklar için soft vurgu rengi seçenekleri
  static const List<Color> habitPalette = [
    Color(0xFF3B6E52), // Adaçayı
    Color(0xFF4A7298), // Soft Mavi
    Color(0xFF7C6DAF), // Soft Lavanta
    Color(0xFFD97757), // Sıcak Terrakotta
    Color(0xFFC8657B), // Soft Gül
    Color(0xFFD49B35), // Bal Sarısı
    Color(0xFF3D8B8B), // Soft Turkuaz
    Color(0xFF6E7D88), // Kül Grisi
  ];
}
