import 'package:flutter/material.dart';

/// Gece spor salonu paleti (Dark Obsidian & Neon)
abstract final class AppColor {
  // Arka plan ve yüzey renkleri (Dark Obsidian)
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF181B22);
  static const Color surfaceVariant = Color(0xFF222631);
  static const Color border = Color(0xFF2C3241);

  // Neon vurgular (Su ve Hidrasyon)
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonBlue = Color(0xFF0088FF);

  // Neon vurgular (Egzersiz ve Kalori)
  static const Color neonLime = Color(0xFF39FF14);
  static const Color neonAmber = Color(0xFFFF9F1C);
  static const Color neonRose = Color(0xFFFF2A6D);

  // Neon vurgular (Uyku ve Dinlenme)
  static const Color neonPurple = Color(0xFFB388FF);

  // Metin renkleri
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}
