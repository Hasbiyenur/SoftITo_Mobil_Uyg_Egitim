import 'package:flutter/foundation.dart';

@immutable
class HabitSchedule {
  final String id;
  final String habitId;
  final int intervalDays; // 1 = Her gün, 2 = 2 günde bir, vb. (1-365)
  final String anchorDateKey; // Başlangıç tarihi "yyyy-MM-dd"
  final String counterType; // 'check' veya 'counter'
  final int targetValue; // Tik için 1, bar için 1-10000
  final String unit; // bar için 'bardak', 'sayfa', 'dakika' vb.
  final int step; // bar için artış adımı, varsayılan 1
  final String targetTime; // "HH:mm", varsayılan "21:00"
  final bool reminderEnabled; // varsayılan true
  final String effectiveFromDateKey; // Bu sürümün geçerli olmaya başladığı tarih "yyyy-MM-dd"

  const HabitSchedule({
    required this.id,
    required this.habitId,
    required this.intervalDays,
    required this.anchorDateKey,
    required this.counterType,
    required this.targetValue,
    this.unit = '',
    this.step = 1,
    this.targetTime = '21:00',
    this.reminderEnabled = true,
    required this.effectiveFromDateKey,
  });

  bool get isCheckType => counterType == 'check';
  bool get isCounterType => counterType == 'counter';

  HabitSchedule copyWith({
    String? id,
    String? habitId,
    int? intervalDays,
    String? anchorDateKey,
    String? counterType,
    int? targetValue,
    String? unit,
    int? step,
    String? targetTime,
    bool? reminderEnabled,
    String? effectiveFromDateKey,
  }) {
    return HabitSchedule(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      intervalDays: intervalDays ?? this.intervalDays,
      anchorDateKey: anchorDateKey ?? this.anchorDateKey,
      counterType: counterType ?? this.counterType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      step: step ?? this.step,
      targetTime: targetTime ?? this.targetTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      effectiveFromDateKey: effectiveFromDateKey ?? this.effectiveFromDateKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'intervalDays': intervalDays,
    'anchorDateKey': anchorDateKey,
    'counterType': counterType,
    'targetValue': targetValue,
    'unit': unit,
    'step': step,
    'targetTime': targetTime,
    'reminderEnabled': reminderEnabled,
    'effectiveFromDateKey': effectiveFromDateKey,
  };

  factory HabitSchedule.fromJson(Map<String, dynamic> json) {
    return HabitSchedule(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      intervalDays: json['intervalDays'] as int,
      anchorDateKey: json['anchorDateKey'] as String,
      counterType: json['counterType'] as String,
      targetValue: json['targetValue'] as int,
      unit: (json['unit'] as String?) ?? '',
      step: (json['step'] as int?) ?? 1,
      targetTime: (json['targetTime'] as String?) ?? '21:00',
      reminderEnabled: (json['reminderEnabled'] as bool?) ?? true,
      effectiveFromDateKey: json['effectiveFromDateKey'] as String,
    );
  }
}
