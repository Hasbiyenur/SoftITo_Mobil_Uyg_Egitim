import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'habit_schedule.dart';

@immutable
class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final int iconCodePoint;
  final int colorValue;
  final String createdAtUtc;
  final String? archivedAtUtc;
  final String? archivedOnDateKey;
  final List<HabitSchedule> schedules;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAtUtc,
    this.archivedAtUtc,
    this.archivedOnDateKey,
    required this.schedules,
  });

  bool get isArchived => archivedAtUtc != null;

  /// Belirli bir takvim gününde yürürlükte olan plan sürümünü bulur.
  /// effectiveFromDateKey <= dateKey koşulunu sağlayan sürümlerden
  /// en son yürürlüğe girmiş olanı döndürür.
  HabitSchedule activeScheduleForDate(String dateKey) {
    if (schedules.isEmpty) {
      throw StateError('Alışkanlık için tanımlı plan bulunamadı: $id');
    }
    // effectiveFromDateKey <= dateKey olanlar
    final validSchedules = schedules
        .where((s) => s.effectiveFromDateKey.compareTo(dateKey) <= 0)
        .toList();

    if (validSchedules.isNotEmpty) {
      validSchedules.sort(
        (a, b) => b.effectiveFromDateKey.compareTo(a.effectiveFromDateKey),
      );
      return validSchedules.first;
    }
    // Eğer tüm sürümler bu tarihten sonra başlıyorsa, en eski sürümü döndür
    final sorted = List<HabitSchedule>.from(
      schedules,
    )..sort((a, b) => a.effectiveFromDateKey.compareTo(b.effectiveFromDateKey));
    return sorted.first;
  }

  /// En güncel / son yürürlüğe giren plan sürümü
  HabitSchedule get latestSchedule {
    if (schedules.isEmpty) {
      throw StateError('Alışkanlık için tanımlı plan bulunamadı: $id');
    }
    final sorted = List<HabitSchedule>.from(
      schedules,
    )..sort((a, b) => b.effectiveFromDateKey.compareTo(a.effectiveFromDateKey));
    return sorted.first;
  }

  Color get color => Color(colorValue);
  String get colorHex {
    final rgb = colorValue & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? iconCodePoint,
    int? colorValue,
    String? createdAtUtc,
    String? archivedAtUtc,
    String? archivedOnDateKey,
    List<HabitSchedule>? schedules,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      archivedAtUtc: archivedAtUtc ?? this.archivedAtUtc,
      archivedOnDateKey: archivedOnDateKey ?? this.archivedOnDateKey,
      schedules: schedules ?? this.schedules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'colorHex': colorHex,
    'createdAtUtc': createdAtUtc,
    'archivedAtUtc': archivedAtUtc,
    'archivedOnDateKey': archivedOnDateKey,
    'schedules': schedules.map((s) => s.toJson()).toList(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final rawSchedules = json['schedules'] as List<dynamic>? ?? [];

    int parsedColorValue = 0xFF3B6E52;
    if (json['colorValue'] is int) {
      parsedColorValue = json['colorValue'] as int;
    } else if (json['colorHex'] is String) {
      final hex = (json['colorHex'] as String).replaceAll('#', '');
      final clean = hex.length == 6 ? 'FF$hex' : hex;
      parsedColorValue = int.tryParse(clean, radix: 16) ?? 0xFF3B6E52;
    }

    return Habit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconCodePoint: (json['iconCodePoint'] as int?) ?? 0xe3e3,
      colorValue: parsedColorValue,
      createdAtUtc: json['createdAtUtc'] as String,
      archivedAtUtc: json['archivedAtUtc'] as String?,
      archivedOnDateKey: json['archivedOnDateKey'] as String?,
      schedules: rawSchedules
          .map((s) => HabitSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
