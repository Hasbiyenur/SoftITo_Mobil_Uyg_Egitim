import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static const String fontName = 'Outfit';

  // Scales from design.md
  static const double sizeDisplayLarge = 28.0;
  static const double sizeTitleLarge = 24.0;
  static const double sizeTitleMedium = 18.0;
  static const double sizeBody = 16.0;
  static const double sizeSubtext = 14.0;
  static const double sizeLabel = 12.0;
  static const double sizeTiny = 10.0;

  static TextStyle displayLarge({required Color color}) => GoogleFonts.outfit(
    fontSize: sizeDisplayLarge,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle titleLarge({required Color color}) => GoogleFonts.outfit(
    fontSize: sizeTitleLarge,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: color,
    letterSpacing: -0.3,
  );

  static TextStyle titleMedium({required Color color}) => GoogleFonts.outfit(
    fontSize: sizeTitleMedium,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: color,
  );

  static TextStyle bodyLarge({
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: sizeBody,
    fontWeight: fontWeight,
    height: 1.5,
    color: color,
  );

  static TextStyle bodyMedium({
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: sizeSubtext,
    fontWeight: fontWeight,
    height: 1.45,
    color: color,
  );

  static TextStyle labelSmall({
    required Color color,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: sizeLabel,
    fontWeight: fontWeight,
    height: 1.3,
    color: color,
  );

  static TextStyle caption({required Color color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: sizeTiny,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: color,
      );
}
