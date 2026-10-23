import 'package:flutter/foundation.dart';

@immutable
class PomodoroState {
  final String userId;
  final String phase; // 'focus', 'shortBreak', 'longBreak'
  final String status; // 'ready', 'running', 'paused'
  final int cycleCompletedCount; // 0..4 (kaç çalışma tamamlandı)
  final String? activeSessionId;
  final String? taskId;
  final String? titleSnapshot;
  final int plannedSeconds;
  final int remainingSeconds;
  final String? startedAtUtc;
  final String? lastResumedAtUtc;
  final String? endsAtUtc;
  final int accumulatedActiveSeconds;

  const PomodoroState({
    required this.userId,
    this.phase = 'focus',
    this.status = 'ready',
    this.cycleCompletedCount = 0,
    this.activeSessionId,
    this.taskId,
    this.titleSnapshot,
    this.plannedSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.startedAtUtc,
    this.lastResumedAtUtc,
    this.endsAtUtc,
    this.accumulatedActiveSeconds = 0,
  });

  factory PomodoroState.initial(String userId, [int focusMinutes = 25]) {
    final seconds = focusMinutes * 60;
    return PomodoroState(
      userId: userId,
      phase: 'focus',
      status: 'ready',
      cycleCompletedCount: 0,
      plannedSeconds: seconds,
      remainingSeconds: seconds,
    );
  }

  bool get isRunning => status == 'running';
  bool get isPaused => status == 'paused';
  bool get isReady => status == 'ready';
  bool get isFocus => phase == 'focus';
  bool get isShortBreak => phase == 'shortBreak';
  bool get isLongBreak => phase == 'longBreak';

  PomodoroState copyWith({
    String? userId,
    String? phase,
    String? status,
    int? cycleCompletedCount,
    String? activeSessionId,
    bool clearActiveSession = false,
    String? taskId,
    bool clearTask = false,
    String? titleSnapshot,
    bool clearTitle = false,
    int? plannedSeconds,
    int? remainingSeconds,
    String? startedAtUtc,
    String? lastResumedAtUtc,
    String? endsAtUtc,
    bool clearEndsAt = false,
    int? accumulatedActiveSeconds,
  }) {
    return PomodoroState(
      userId: userId ?? this.userId,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      cycleCompletedCount: cycleCompletedCount ?? this.cycleCompletedCount,
      activeSessionId: clearActiveSession
          ? null
          : (activeSessionId ?? this.activeSessionId),
      taskId: clearTask ? null : (taskId ?? this.taskId),
      titleSnapshot: clearTitle ? null : (titleSnapshot ?? this.titleSnapshot),
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      lastResumedAtUtc: lastResumedAtUtc ?? this.lastResumedAtUtc,
      endsAtUtc: clearEndsAt ? null : (endsAtUtc ?? this.endsAtUtc),
      accumulatedActiveSeconds:
          accumulatedActiveSeconds ?? this.accumulatedActiveSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'phase': phase,
    'status': status,
    'cycleCompletedCount': cycleCompletedCount,
    'activeSessionId': activeSessionId,
    'taskId': taskId,
    'titleSnapshot': titleSnapshot,
    'plannedSeconds': plannedSeconds,
    'remainingSeconds': remainingSeconds,
    'startedAtUtc': startedAtUtc,
    'lastResumedAtUtc': lastResumedAtUtc,
    'endsAtUtc': endsAtUtc,
    'accumulatedActiveSeconds': accumulatedActiveSeconds,
  };

  factory PomodoroState.fromJson(Map<String, dynamic> json) {
    return PomodoroState(
      userId: json['userId'] as String,
      phase: (json['phase'] as String?) ?? 'focus',
      status: (json['status'] as String?) ?? 'ready',
      cycleCompletedCount: (json['cycleCompletedCount'] as int?) ?? 0,
      activeSessionId: json['activeSessionId'] as String?,
      taskId: json['taskId'] as String?,
      titleSnapshot: json['titleSnapshot'] as String?,
      plannedSeconds: (json['plannedSeconds'] as int?) ?? (25 * 60),
      remainingSeconds: (json['remainingSeconds'] as int?) ?? (25 * 60),
      startedAtUtc: json['startedAtUtc'] as String?,
      lastResumedAtUtc: json['lastResumedAtUtc'] as String?,
      endsAtUtc: json['endsAtUtc'] as String?,
      accumulatedActiveSeconds: (json['accumulatedActiveSeconds'] as int?) ?? 0,
    );
  }
}
