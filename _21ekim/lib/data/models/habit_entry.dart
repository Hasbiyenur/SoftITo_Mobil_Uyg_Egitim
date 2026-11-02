import 'package:flutter/foundation.dart';

@immutable
class HabitEntry {
  final String id;
  final String userId;
  final String habitId;
  final String scheduleId;
  final String dateKey; // "yyyy-MM-dd"
  final int progressValue;
  final int targetValue;
  final String? completedAtUtc; // ISO 8601, tamamlandığı an; geri alınırsa null
  final String updatedAtUtc;

  const HabitEntry({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.scheduleId,
    required this.dateKey,
    required this.progressValue,
    required this.targetValue,
    this.completedAtUtc,
    required this.updatedAtUtc,
  });

  bool get isCompleted => progressValue >= targetValue && targetValue > 0;

  double get ratio {
    if (targetValue <= 0) return 0;
    final r = progressValue / targetValue;
    return r > 1.0 ? 1.0 : (r < 0.0 ? 0.0 : r);
  }

  HabitEntry copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? scheduleId,
    String? dateKey,
    int? progressValue,
    int? targetValue,
    String? completedAtUtc,
    bool clearCompletedAt = false,
    String? updatedAtUtc,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      scheduleId: scheduleId ?? this.scheduleId,
      dateKey: dateKey ?? this.dateKey,
      progressValue: progressValue ?? this.progressValue,
      targetValue: targetValue ?? this.targetValue,
      completedAtUtc: clearCompletedAt
          ? null
          : (completedAtUtc ?? this.completedAtUtc),
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'habitId': habitId,
    'scheduleId': scheduleId,
    'dateKey': dateKey,
    'progressValue': progressValue,
    'targetValue': targetValue,
    'completedAtUtc': completedAtUtc,
    'updatedAtUtc': updatedAtUtc,
  };

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      scheduleId: json['scheduleId'] as String,
      dateKey: json['dateKey'] as String,
      progressValue: json['progressValue'] as int,
      targetValue: json['targetValue'] as int,
      completedAtUtc: json['completedAtUtc'] as String?,
      updatedAtUtc: json['updatedAtUtc'] as String,
    );
  }
}
