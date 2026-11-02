import 'package:flutter/foundation.dart';

@immutable
class Achievement {
  final String id;
  final String userId;
  final String type; // 'bronze', 'silver', 'gold'
  final String title; // 'Bronz Başlangıç', 'Gümüş Devamlılık', 'Altın İstikrar'
  final int threshold; // 10, 25, 50
  final String habitId;
  final String habitTitle;
  final String unlockedDateKey; // "yyyy-MM-dd"
  final String unlockedAtUtc; // ISO 8601

  const Achievement({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.threshold,
    required this.habitId,
    required this.habitTitle,
    required this.unlockedDateKey,
    required this.unlockedAtUtc,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'title': title,
    'threshold': threshold,
    'habitId': habitId,
    'habitTitle': habitTitle,
    'unlockedDateKey': unlockedDateKey,
    'unlockedAtUtc': unlockedAtUtc,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      threshold: json['threshold'] as int,
      habitId: json['habitId'] as String,
      habitTitle: json['habitTitle'] as String,
      unlockedDateKey: json['unlockedDateKey'] as String,
      unlockedAtUtc: json['unlockedAtUtc'] as String,
    );
  }
}
