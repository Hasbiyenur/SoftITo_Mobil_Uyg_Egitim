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
  final String? celebrationShownAtUtc; // İlk kutlamada doldurulur, geriye dönük uyumluluk için saklanır
  final int completionRevision; // Tamamlanmaya her geçişte artar (0'dan başlar)
  final int lastCelebratedRevision; // Son kutlanan revizyon
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
    this.celebrationShownAtUtc,
    this.completionRevision = 0,
    this.lastCelebratedRevision = 0,
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
    String? celebrationShownAtUtc,
    int? completionRevision,
    int? lastCelebratedRevision,
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
      celebrationShownAtUtc:
          celebrationShownAtUtc ?? this.celebrationShownAtUtc,
      completionRevision: completionRevision ?? this.completionRevision,
      lastCelebratedRevision:
          lastCelebratedRevision ?? this.lastCelebratedRevision,
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
    'celebrationShownAtUtc': celebrationShownAtUtc,
    'completionRevision': completionRevision,
    'lastCelebratedRevision': lastCelebratedRevision,
    'updatedAtUtc': updatedAtUtc,
  };

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    final completed = json['completedAtUtc'] != null;
    return HabitEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      habitId: json['habitId'] as String,
      scheduleId: json['scheduleId'] as String,
      dateKey: json['dateKey'] as String,
      progressValue: json['progressValue'] as int,
      targetValue: json['targetValue'] as int,
      completedAtUtc: json['completedAtUtc'] as String?,
      celebrationShownAtUtc: json['celebrationShownAtUtc'] as String?,
      completionRevision:
          json['completionRevision'] as int? ?? (completed ? 1 : 0),
      lastCelebratedRevision:
          json['lastCelebratedRevision'] as int? ?? (completed ? 1 : 0),
      updatedAtUtc: json['updatedAtUtc'] as String,
    );
  }
}
