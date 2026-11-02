import 'package:flutter/foundation.dart';

@immutable
class PomodoroPreferences {
  final String userId;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  const PomodoroPreferences({
    required this.userId,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
  });

  factory PomodoroPreferences.defaults(String userId) {
    return PomodoroPreferences(
      userId: userId,
      focusMinutes: 25,
      shortBreakMinutes: 5,
      longBreakMinutes: 15,
    );
  }

  PomodoroPreferences copyWith({
    String? userId,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    return PomodoroPreferences(
      userId: userId ?? this.userId,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    );
  }

  static String? validateFocusMinutes(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Çalışma süresi boş bırakılamaz.';
    }
    final val = int.tryParse(input.trim());
    if (val == null) {
      return 'Lütfen tam sayı giriniz (örn: 25).';
    }
    if (val < 1 || val > 180) {
      return 'Çalışma süresi 1–180 dakika arasında olmalıdır.';
    }
    return null;
  }

  static String? validateShortBreakMinutes(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Kısa mola süresi boş bırakılamaz.';
    }
    final val = int.tryParse(input.trim());
    if (val == null) {
      return 'Lütfen tam sayı giriniz (örn: 5).';
    }
    if (val < 1 || val > 60) {
      return 'Kısa mola 1–60 dakika arasında olmalıdır.';
    }
    return null;
  }

  static String? validateLongBreakMinutes(
    String? input,
    int shortBreakMinutes,
  ) {
    if (input == null || input.trim().isEmpty) {
      return 'Uzun mola süresi boş bırakılamaz.';
    }
    final val = int.tryParse(input.trim());
    if (val == null) {
      return 'Lütfen tam sayı giriniz (örn: 15).';
    }
    if (val < 1 || val > 120) {
      return 'Uzun mola 1–120 dakika arasında olmalıdır.';
    }
    if (val < shortBreakMinutes) {
      return 'Uzun mola kısa moladan daha kısa olamaz.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'focusMinutes': focusMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
  };

  factory PomodoroPreferences.fromJson(Map<String, dynamic> json) {
    return PomodoroPreferences(
      userId: json['userId'] as String,
      focusMinutes: (json['focusMinutes'] as int?) ?? 25,
      shortBreakMinutes: (json['shortBreakMinutes'] as int?) ?? 5,
      longBreakMinutes: (json['longBreakMinutes'] as int?) ?? 15,
    );
  }
}
