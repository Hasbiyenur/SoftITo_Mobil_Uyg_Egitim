import 'package:flutter/foundation.dart';

@immutable
class HabitReminder {
  final String id;
  final String userId;
  final String habitId;
  final String habitTitle;
  final String dateKey; // "yyyy-MM-dd"
  final String reminderTime; // "HH:mm" (hedef saatinden 1 saat önce)
  final bool isRead;
  final String createdAtUtc;
  final String message;

  const HabitReminder({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.habitTitle,
    required this.dateKey,
    required this.reminderTime,
    this.isRead = false,
    required this.createdAtUtc,
    required this.message,
  });

  HabitReminder copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? habitTitle,
    String? dateKey,
    String? reminderTime,
    bool? isRead,
    String? createdAtUtc,
    String? message,
  }) {
    return HabitReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      habitTitle: habitTitle ?? this.habitTitle,
      dateKey: dateKey ?? this.dateKey,
      reminderTime: reminderTime ?? this.reminderTime,
      isRead: isRead ?? this.isRead,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'habitId': habitId,
    'habitTitle': habitTitle,
    'dateKey': dateKey,
    'reminderTime': reminderTime,
    'isRead': isRead,
    'createdAtUtc': createdAtUtc,
    'message': message,
  };

  factory HabitReminder.fromJson(Map<String, dynamic> json) {
    return HabitReminder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      habitTitle: json['habitTitle'] as String,
      dateKey: json['dateKey'] as String,
      reminderTime: json['reminderTime'] as String,
      isRead: (json['isRead'] as bool?) ?? false,
      createdAtUtc: json['createdAtUtc'] as String,
      message: json['message'] as String,
    );
  }
}
