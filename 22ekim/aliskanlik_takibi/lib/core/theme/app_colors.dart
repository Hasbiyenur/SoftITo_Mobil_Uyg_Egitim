import 'package:flutter/material.dart';

/// Uygulamanın soft, göz yormayan, pastel Material 3 açık ve koyu renk paleti.
class AppColors {
  AppColors._();

  // --- AÇIK TEMA RENKLERİ ---
  // Ana renkler
  static const Color primary = Color(0xFF4F6F52); // Koyu adaçayı birincil
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE4EDDF); // Açık adaçayı yüzey
  static const Color onPrimaryContainer = Color(0xFF1E3322);

  static const Color secondary = Color(0xFF56645C); // İkincil adaçayı gri
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFECE8F3); // Lavanta yüzey
  static const Color onSecondaryContainer = Color(0xFF26332D);

  // Arka plan ve kart yüzeyleri
  static const Color background = Color(0xFFF7F8F5); // Kırık beyaz
  static const Color onBackground = Color(0xFF26332D); // Ana metin
  static const Color surface = Color(0xFFFFFFFF); // Beyaz kart
  static const Color onSurface = Color(0xFF26332D);
  static const Color surfaceVariant = Color(0xFFE5EEF4); // Mavi yüzey
  static const Color onSurfaceVariant = Color(0xFF56645C); // İkincil metin

  // Durum ve uyarı renkleri (soft)
  static const Color success = Color(0xFF43936C);
  static const Color error = Color(0xFF8F4942); // Hata / kaldırma
  static const Color onError = Colors.white;
  static const Color warning = Color(0xFF775528); // Uyarı metni
  static const Color info = Color(0xFF3E82AF);

  // Tamamlanmış öğeler
  static const Color completedSurface = Color(0xFFF1F5F2);
  static const Color completedText = Color(0xFF8A9BA8);
  static const Color completedBorder = Color(0xFFD2DCD5);

  // Çizgi ve kenarlıklar
  static const Color outline = Color(0xFFDCE3DC); // Kenarlık
  static const Color outlineVariant = Color(0xFFE8ECE9);

  // --- KOYU TEMA RENKLERİ ---
  static const Color darkBackground = Color(0xFF18201D); // Koyu arka plan
  static const Color darkSurface = Color(0xFF242D29); // Koyu kart / yüzey
  static const Color darkPrimary = Color(0xFFAEC9A5); // Açık adaçayı birincil
  static const Color darkOnPrimary = Color(
    0xFF18201D,
  ); // Birincil üzeri koyu metin
  static const Color darkPrimaryContainer = Color(0xFF2E3E34);
  static const Color darkOnPrimaryContainer = Color(0xFFD3E7CE);

  static const Color darkSecondary = Color(0xFF9EB0A6);
  static const Color darkOnSecondary = Color(0xFF18201D);
  static const Color darkSecondaryContainer = Color(0xFF323D38);
  static const Color darkOnSecondaryContainer = Color(0xFFEEF3EF);

  static const Color darkOnBackground = Color(0xFFEEF3EF); // Açık ana metin
  static const Color darkOnSurface = Color(0xFFEEF3EF);
  static const Color darkSurfaceVariant = Color(0xFF2C3732);
  static const Color darkOnSurfaceVariant = Color(
    0xFFB7C5BC,
  ); // Açık ikincil metin

  static const Color darkOutline = Color(0xFF3C4A42); // Koyu kenarlık
  static const Color darkOutlineVariant = Color(0xFF2E3A33);

  static const Color darkError = Color(
    0xFFE9ADA5,
  ); // Koyu temada soft kırmızı/pembe
  static const Color darkOnError = Color(0xFF381E1C);
  static const Color darkWarning = Color(
    0xFFE3C18D,
  ); // Koyu temada soft sarı/bal

  static const Color darkCompletedSurface = Color(0xFF1F2723);
  static const Color darkCompletedText = Color(0xFF8F9E95);
  static const Color darkCompletedBorder = Color(0xFF2F3A33);

  // Alışkanlıklar için soft vurgu rengi seçenekleri
  static const List<Color> habitPalette = [
    Color(0xFF4F6F52), // Adaçayı
    Color(0xFF4A7298), // Soft Mavi
    Color(0xFF7C6DAF), // Soft Lavanta
    Color(0xFFD97757), // Sıcak Terrakotta
    Color(0xFFC8657B), // Soft Gül
    Color(0xFFD49B35), // Bal Sarısı
    Color(0xFF3D8B8B), // Soft Turkuaz
    Color(0xFF6E7D88), // Kül Grisi
  ];
}
