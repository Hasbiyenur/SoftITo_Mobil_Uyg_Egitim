import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  final String userId;
  final String themeMode; // 'light' veya 'dark'

  const AppSettings({required this.userId, this.themeMode = 'light'});

  bool get isDarkMode => themeMode == 'dark';

  AppSettings copyWith({String? userId, String? themeMode}) {
    return AppSettings(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {'userId': userId, 'themeMode': themeMode};

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userId: json['userId'] as String,
      themeMode: (json['themeMode'] as String?) ?? 'light',
    );
  }
}
