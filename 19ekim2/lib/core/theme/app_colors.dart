import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Koyu Mod (Dark Obsidian) Renkleri
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color surfaceDark = Color(0xFF131B2A);
  static const Color surfaceElevatedDark = Color(0xFF1C273C);
  static const Color borderDark = Color(0xFF26354D);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color primaryAquaDark = Color(0xFF00E5FF);
  static const Color energyLimeDark = Color(0xFF00E676);
  static const Color energyOrangeDark = Color(0xFFFF9100);
  static const Color energyCoralDark = Color(0xFFFF5252);

  // Aydınlık Mod (Light Ice / Slate) Renkleri
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color primaryAquaLight = Color(0xFF0284C7);
  static const Color energyLimeLight = Color(0xFF16A34A);
  static const Color energyOrangeLight = Color(0xFFEA580C);
  static const Color energyCoralLight = Color(0xFFDC2626);

  // Ortak Gradient Renkleri
  static const Color primaryBlue = Color(0xFF0072FF);
  static const Color cyanGradientStart = Color(0xFF00F2FE);
  static const Color cyanGradientEnd = Color(0xFF4FACFE);

  // Geriye Dönük Uyumluluk Değerleri (Varsayılan Koyu)
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color surfaceElevated = surfaceElevatedDark;
  static const Color border = borderDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted = textMutedDark;
  static const Color primaryAqua = primaryAquaDark;
  static const Color energyLime = energyLimeDark;
  static const Color energyOrange = energyOrangeDark;
  static const Color energyCoral = energyCoralDark;

  // Dinamik Context Yardımcı Metotları
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color surfaceElevatedOf(BuildContext context) =>
      isDark(context) ? surfaceElevatedDark : surfaceElevatedLight;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? borderDark : borderLight;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? textMutedDark : textMutedLight;

  static Color primaryAquaOf(BuildContext context) =>
      isDark(context) ? primaryAquaDark : primaryAquaLight;

  static Color energyLimeOf(BuildContext context) =>
      isDark(context) ? energyLimeDark : energyLimeLight;

  static Color energyOrangeOf(BuildContext context) =>
      isDark(context) ? energyOrangeDark : energyOrangeLight;

  static Color energyCoralOf(BuildContext context) =>
      isDark(context) ? energyCoralDark : energyCoralLight;
}
