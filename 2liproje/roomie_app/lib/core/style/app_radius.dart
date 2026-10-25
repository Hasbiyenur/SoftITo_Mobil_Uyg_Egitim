import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double input = 12.0;
  static const double card = 16.0;
  static const double modal = 20.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius modalRadius = BorderRadius.vertical(
    top: Radius.circular(modal),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(full),
  );
}
