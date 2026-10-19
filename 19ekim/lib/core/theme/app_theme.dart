import 'package:flutter/material.dart';
import '../constants/app_color.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColor.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColor.surface,
        surfaceContainerHighest: AppColor.surfaceVariant,
        primary: AppColor.neonCyan,
        secondary: AppColor.neonLime,
        tertiary: AppColor.neonAmber,
        onSurface: AppColor.textPrimary,
        outline: AppColor.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColor.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColor.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColor.border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColor.surface,
        indicatorColor: AppColor.neonCyan.withAlpha(40),
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColor.neonCyan,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColor.textSecondary,
            fontSize: 12,
          );
        }),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColor.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColor.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColor.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColor.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: AppColor.textMuted,
        ),
      ),
    );
  }
}
