import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_entry.dart';
import '../../data/models/achievement.dart';
import '../../data/models/habit_reminder.dart';

@immutable
class StoreDocument {
  final int schemaVersion;
  final String? activeUserId;
  final int demoSeedVersion;
  final List<AppUser> users;
  final List<Habit> habits;
  final List<HabitEntry> entries;
  final List<Achievement> achievements;
  final List<HabitReminder> reminders;

  const StoreDocument({
    this.schemaVersion = 1,
    this.activeUserId,
    this.demoSeedVersion = 0,
    this.users = const [],
    this.habits = const [],
    this.entries = const [],
    this.achievements = const [],
    this.reminders = const [],
  });

  StoreDocument copyWith({
    int? schemaVersion,
    String? activeUserId,
    bool clearActiveUser = false,
    int? demoSeedVersion,
    List<AppUser>? users,
    List<Habit>? habits,
    List<HabitEntry>? entries,
    List<Achievement>? achievements,
    List<HabitReminder>? reminders,
  }) {
    return StoreDocument(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      activeUserId: clearActiveUser
          ? null
          : (activeUserId ?? this.activeUserId),
      demoSeedVersion: demoSeedVersion ?? this.demoSeedVersion,
      users: users ?? this.users,
      habits: habits ?? this.habits,
      entries: entries ?? this.entries,
      achievements: achievements ?? this.achievements,
      reminders: reminders ?? this.reminders,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'activeUserId': activeUserId,
    'demoSeedVersion': demoSeedVersion,
    'users': users.map((u) => u.toJson()).toList(),
    'habits': habits.map((h) => h.toJson()).toList(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'reminders': reminders.map((r) => r.toJson()).toList(),
  };

  factory StoreDocument.fromJson(Map<String, dynamic> json) {
    return StoreDocument(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      activeUserId: json['activeUserId'] as String?,
      demoSeedVersion: (json['demoSeedVersion'] as int?) ?? 0,
      users: (json['users'] as List<dynamic>? ?? [])
          .map((u) => AppUser.fromJson(u as Map<String, dynamic>))
          .toList(),
      habits: (json['habits'] as List<dynamic>? ?? [])
          .map((h) => Habit.fromJson(h as Map<String, dynamic>))
          .toList(),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((e) => HabitEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList(),
      reminders: (json['reminders'] as List<dynamic>? ?? [])
          .map((r) => HabitReminder.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
