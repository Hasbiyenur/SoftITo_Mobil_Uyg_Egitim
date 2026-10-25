import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double standard = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen horizontal padding
  static const double screenMargin = 20.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenMargin,
  );
  static const EdgeInsets screenPaddingWithTop = EdgeInsets.fromLTRB(
    screenMargin,
    16.0,
    screenMargin,
    24.0,
  );
}
