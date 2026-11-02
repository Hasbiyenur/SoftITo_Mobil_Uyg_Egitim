import 'package:flutter/foundation.dart';

import '../theme/habit_color_service.dart';
import '../../data/models/achievement.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/app_user.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_entry.dart';
import '../../data/models/habit_reminder.dart';
import '../../data/models/motivation_message.dart';
import '../../data/models/motivation_preferences.dart';
import '../../data/models/pomodoro_preferences.dart';
import '../../data/models/pomodoro_session.dart';
import '../../data/models/pomodoro_state.dart';

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
  final Map<String, AppSettings> appSettingsByUser;
  final Map<String, PomodoroPreferences> pomodoroPreferencesByUser;
  final Map<String, PomodoroState> pomodoroStatesByUser;
  final List<PomodoroSession> pomodoroSessions;
  final Map<String, MotivationPreferences> motivationPreferencesByUser;
  final List<MotivationMessage> motivationCache;
  final String? motivationCacheFetchedAtUtc;

  const StoreDocument({
    this.schemaVersion = 4,
    this.activeUserId,
    this.demoSeedVersion = 0,
    this.users = const [],
    this.habits = const [],
    this.entries = const [],
    this.achievements = const [],
    this.reminders = const [],
    this.appSettingsByUser = const {},
    this.pomodoroPreferencesByUser = const {},
    this.pomodoroStatesByUser = const {},
    this.pomodoroSessions = const [],
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
    Map<String, AppSettings>? appSettingsByUser,
    Map<String, PomodoroPreferences>? pomodoroPreferencesByUser,
    Map<String, PomodoroState>? pomodoroStatesByUser,
    List<PomodoroSession>? pomodoroSessions,
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
      appSettingsByUser: appSettingsByUser ?? this.appSettingsByUser,
      pomodoroPreferencesByUser:
          pomodoroPreferencesByUser ?? this.pomodoroPreferencesByUser,
      pomodoroStatesByUser: pomodoroStatesByUser ?? this.pomodoroStatesByUser,
      pomodoroSessions: pomodoroSessions ?? this.pomodoroSessions,
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
    'appSettingsByUser': appSettingsByUser.map(
      (k, v) => MapEntry(k, v.toJson()),
    ),
    'pomodoroPreferencesByUser': pomodoroPreferencesByUser.map(
      (k, v) => MapEntry(k, v.toJson()),
    ),
    'pomodoroStatesByUser': pomodoroStatesByUser.map(
      (k, v) => MapEntry(k, v.toJson()),
    ),
    'pomodoroSessions': pomodoroSessions.map((s) => s.toJson()).toList(),
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

    var rawUsers = (json['users'] as List<dynamic>? ?? [])
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

    // AppSettings haritası
    final Map<String, AppSettings> appSettingsMap = {};
    if (json['appSettingsByUser'] is Map<String, dynamic>) {
      final rawSettings = json['appSettingsByUser'] as Map<String, dynamic>;
      rawSettings.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          appSettingsMap[k] = AppSettings.fromJson(v);
        }
      });
    }

    // Pomodoro Tercihleri haritası
    final Map<String, PomodoroPreferences> pomodoroPrefsMap = {};
    if (json['pomodoroPreferencesByUser'] is Map<String, dynamic>) {
      final rawP = json['pomodoroPreferencesByUser'] as Map<String, dynamic>;
      rawP.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          pomodoroPrefsMap[k] = PomodoroPreferences.fromJson(v);
        }
      });
    }

    // Pomodoro Durumları haritası
    final Map<String, PomodoroState> pomodoroStatesMap = {};
    if (json['pomodoroStatesByUser'] is Map<String, dynamic>) {
      final rawS = json['pomodoroStatesByUser'] as Map<String, dynamic>;
      rawS.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          pomodoroStatesMap[k] = PomodoroState.fromJson(v);
        }
      });
    }

    // Pomodoro Oturum Geçmişi
    final List<PomodoroSession> pomodoroSessionsList = [];
    if (json['pomodoroSessions'] is List<dynamic>) {
      for (final s in (json['pomodoroSessions'] as List<dynamic>)) {
        if (s is Map<String, dynamic>) {
          pomodoroSessionsList.add(PomodoroSession.fromJson(s));
        }
      }
    }

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

    // Sürüm 1 -> 2 Migration:
    // Renk çakışmalarını gider ve eksik motivasyon tercihleri ekle
    if (rawVersion < 2) {
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

      for (final u in rawUsers) {
        if (!prefsMap.containsKey(u.id)) {
          prefsMap[u.id] = MotivationPreferences.defaults(u.id);
        }
      }
    }

    // Sürüm 2 -> 3 Migration:
    // Kullanıcının eksik avatarId alanı fox, eksik tema tercihi light olur.
    // Pomodoro durumu hazır çalışma olarak başlatılır.
    if (rawVersion < 3) {
      rawUsers = rawUsers.map((u) {
        if (u.avatarId.isEmpty) {
          return u.copyWith(avatarId: 'fox');
        }
        return u;
      }).toList();

      for (final u in rawUsers) {
        if (!appSettingsMap.containsKey(u.id)) {
          appSettingsMap[u.id] = AppSettings(userId: u.id, themeMode: 'light');
        }
        if (!pomodoroStatesMap.containsKey(u.id)) {
          pomodoroStatesMap[u.id] = PomodoroState.initial(u.id, 25);
        }
      }
    }

    // Sürüm 3 -> 4 Migration:
    // pomodoroPreferencesByUser eklenir; yalnızca tercihi olmayan kullanıcıya 25/5/15 varsayılanları atanır.
    // Var olan geçerli tercihler, etkin/duraklatılmış aşamanın süreleri, döngü sayısı ve geçmiş korunur.
    if (rawVersion < 4) {
      for (final u in rawUsers) {
        if (!pomodoroPrefsMap.containsKey(u.id)) {
          pomodoroPrefsMap[u.id] = PomodoroPreferences.defaults(u.id);
        }
        if (!pomodoroStatesMap.containsKey(u.id)) {
          final userFocus = pomodoroPrefsMap[u.id]!.focusMinutes;
          pomodoroStatesMap[u.id] = PomodoroState.initial(u.id, userFocus);
        }
        if (!appSettingsMap.containsKey(u.id)) {
          appSettingsMap[u.id] = AppSettings(userId: u.id, themeMode: 'light');
        }
      }
    }

    return StoreDocument(
      schemaVersion: 4,
      activeUserId: json['activeUserId'] as String?,
      demoSeedVersion: (json['demoSeedVersion'] as int?) ?? 0,
      users: rawUsers,
      habits: rawHabits,
      entries: rawEntries,
      achievements: rawAchievements,
      reminders: rawReminders,
      appSettingsByUser: appSettingsMap,
      pomodoroPreferencesByUser: pomodoroPrefsMap,
      pomodoroStatesByUser: pomodoroStatesMap,
      pomodoroSessions: pomodoroSessionsList,
      motivationPreferencesByUser: prefsMap,
      motivationCache: cacheMessages,
      motivationCacheFetchedAtUtc: cacheFetchedAtUtc,
    );
  }
}
