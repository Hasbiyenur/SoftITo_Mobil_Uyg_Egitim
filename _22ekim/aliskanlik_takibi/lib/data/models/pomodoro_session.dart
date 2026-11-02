import 'package:flutter/foundation.dart';

@immutable
class PomodoroSession {
  final String id;
  final String userId;
  final String? taskId;
  final String titleSnapshot;
  final String startedAtUtc;
  final String endedAtUtc;
  final String endedOnDateKey; // YYYY-MM-DD
  final int plannedSeconds;
  final int focusedSeconds;
  final String status; // 'completed' veya 'abandoned'

  const PomodoroSession({
    required this.id,
    required this.userId,
    this.taskId,
    required this.titleSnapshot,
    required this.startedAtUtc,
    required this.endedAtUtc,
    required this.endedOnDateKey,
    required this.plannedSeconds,
    required this.focusedSeconds,
    required this.status,
  });

  bool get isCompleted => status == 'completed';
  bool get isAbandoned => status == 'abandoned';

  PomodoroSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? titleSnapshot,
    String? startedAtUtc,
    String? endedAtUtc,
    String? endedOnDateKey,
    int? plannedSeconds,
    int? focusedSeconds,
    String? status,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      endedOnDateKey: endedOnDateKey ?? this.endedOnDateKey,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      focusedSeconds: focusedSeconds ?? this.focusedSeconds,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'taskId': taskId,
    'titleSnapshot': titleSnapshot,
    'startedAtUtc': startedAtUtc,
    'endedAtUtc': endedAtUtc,
    'endedOnDateKey': endedOnDateKey,
    'plannedSeconds': plannedSeconds,
    'focusedSeconds': focusedSeconds,
    'status': status,
  };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String?,
      titleSnapshot: (json['titleSnapshot'] as String?) ?? 'Odaklanma',
      startedAtUtc: json['startedAtUtc'] as String,
      endedAtUtc: json['endedAtUtc'] as String,
      endedOnDateKey: json['endedOnDateKey'] as String,
      plannedSeconds: (json['plannedSeconds'] as int?) ?? (25 * 60),
      focusedSeconds: (json['focusedSeconds'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'completed',
    );
  }
}
