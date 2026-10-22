import 'package:flutter/foundation.dart';

import '../theme/habit_color_service.dart';
import '../../data/models/app_user.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_entry.dart';
import '../../data/models/achievement.dart';
import '../../data/models/habit_reminder.dart';
import '../../data/models/motivation_preferences.dart';
import '../../data/models/motivation_message.dart';

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
  final Map<String, MotivationPreferences> motivationPreferencesByUser;
  final List<MotivationMessage> motivationCache;
  final String? motivationCacheFetchedAtUtc;

  const StoreDocument({
    this.schemaVersion = 2,
    this.activeUserId,
    this.demoSeedVersion = 0,
    this.users = const [],
    this.habits = const [],
    this.entries = const [],
    this.achievements = const [],
    this.reminders = const [],
    this.motivationPreferencesByUser = const {},
    this.motivationCache = const [],
    this.motivationCacheFetchedAtUtc,
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
    Map<String, MotivationPreferences>? motivationPreferencesByUser,
    List<MotivationMessage>? motivationCache,
    String? motivationCacheFetchedAtUtc,
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
      motivationPreferencesByUser:
          motivationPreferencesByUser ?? this.motivationPreferencesByUser,
      motivationCache: motivationCache ?? this.motivationCache,
      motivationCacheFetchedAtUtc:
          motivationCacheFetchedAtUtc ?? this.motivationCacheFetchedAtUtc,
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
    'motivationPreferencesByUser': motivationPreferencesByUser.map(
      (k, v) => MapEntry(k, v.toJson()),
    ),
    'motivationCache': {
      'messages': motivationCache.map((m) => m.toJson()).toList(),
      'fetchedAtUtc': motivationCacheFetchedAtUtc,
    },
  };

  factory StoreDocument.fromJson(Map<String, dynamic> json) {
    final rawVersion = (json['schemaVersion'] as int?) ?? 1;

    final rawUsers = (json['users'] as List<dynamic>? ?? [])
        .map((u) => AppUser.fromJson(u as Map<String, dynamic>))
        .toList();

    var rawHabits = (json['habits'] as List<dynamic>? ?? [])
        .map((h) => Habit.fromJson(h as Map<String, dynamic>))
        .toList();

    final rawEntries = (json['entries'] as List<dynamic>? ?? [])
        .map((e) => HabitEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawAchievements = (json['achievements'] as List<dynamic>? ?? [])
        .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
        .toList();

    final rawReminders = (json['reminders'] as List<dynamic>? ?? [])
        .map((r) => HabitReminder.fromJson(r as Map<String, dynamic>))
        .toList();

    // Motivasyon tercihleri haritası
    final Map<String, MotivationPreferences> prefsMap = {};
    if (json['motivationPreferencesByUser'] is Map<String, dynamic>) {
      final rawPrefs =
          json['motivationPreferencesByUser'] as Map<String, dynamic>;
      rawPrefs.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          prefsMap[k] = MotivationPreferences.fromJson(v);
        }
      });
    }

    // Motivasyon önbelleği
    final List<MotivationMessage> cacheMessages = [];
    String? cacheFetchedAtUtc;
    if (json['motivationCache'] is Map<String, dynamic>) {
      final cacheObj = json['motivationCache'] as Map<String, dynamic>;
      cacheFetchedAtUtc = cacheObj['fetchedAtUtc'] as String?;
      if (cacheObj['messages'] is List<dynamic>) {
        final list = cacheObj['messages'] as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            cacheMessages.add(MotivationMessage.fromJson(item));
          }
        }
      }
    }

    // Sürüm 1 -> 2 Migration Kontrolü:
    // Renk çakışmalarını gider ve eksik kullanıcı tercihleri için varsayılan ata
    if (rawVersion < 2) {
      // Kullanıcı bazında renk çakışmalarını çöz
      final migratedHabits = <Habit>[];
      final userGroups = <String, List<Habit>>{};
      for (final h in rawHabits) {
        userGroups.putIfAbsent(h.userId, () => []).add(h);
      }
      for (final entry in userGroups.entries) {
        final resolved = HabitColorService.resolveColorCollisions(entry.value);
        migratedHabits.addAll(resolved);
      }
      rawHabits = migratedHabits;

      // Eksik kullanıcı tercihleri
      for (final u in rawUsers) {
        if (!prefsMap.containsKey(u.id)) {
          prefsMap[u.id] = MotivationPreferences.defaults(u.id);
        }
      }
    }

    return StoreDocument(
      schemaVersion: 2,
      activeUserId: json['activeUserId'] as String?,
      demoSeedVersion: (json['demoSeedVersion'] as int?) ?? 0,
      users: rawUsers,
      habits: rawHabits,
      entries: rawEntries,
      achievements: rawAchievements,
      reminders: rawReminders,
      motivationPreferencesByUser: prefsMap,
      motivationCache: cacheMessages,
      motivationCacheFetchedAtUtc: cacheFetchedAtUtc,
    );
  }
}
