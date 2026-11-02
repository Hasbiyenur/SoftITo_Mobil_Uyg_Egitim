import '../../core/storage/local_store.dart';
import '../models/achievement.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../models/habit_reminder.dart';
import 'habit_repository.dart';

class LocalHabitRepository implements HabitRepository {
  final LocalStore store;

  LocalHabitRepository({required this.store});

  @override
  Future<List<Habit>> getHabits(String userId) async {
    final doc = await store.load();
    return doc.habits.where((h) => h.userId == userId).toList();
  }

  @override
  Future<Habit?> getHabitById(String userId, String habitId) async {
    final doc = await store.load();
    try {
      return doc.habits.firstWhere(
        (h) => h.userId == userId && h.id == habitId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveHabit(String userId, Habit habit) async {
    if (habit.userId != userId) {
      throw StateError('Yetkisiz işlem: Alışkanlık bu kullanıcıya ait değil.');
    }
    final doc = await store.load();
    final updatedHabits = List<Habit>.from(doc.habits);
    final index = updatedHabits.indexWhere(
      (h) => h.id == habit.id && h.userId == userId,
    );

    if (index >= 0) {
      updatedHabits[index] = habit;
    } else {
      updatedHabits.add(habit);
    }

    final updated = doc.copyWith(habits: updatedHabits);
    await store.save(updated);
  }

  @override
  Future<void> archiveHabits(
    String userId,
    List<String> habitIds,
    String todayKey,
  ) async {
    final doc = await store.load();
    final updatedHabits = doc.habits.map((h) {
      if (h.userId == userId && habitIds.contains(h.id)) {
        return h.copyWith(
          archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
          archivedOnDateKey: todayKey,
        );
      }
      return h;
    }).toList();

    final updated = doc.copyWith(habits: updatedHabits);
    await store.save(updated);
  }

  @override
  Future<List<HabitEntry>> getEntries(String userId) async {
    final doc = await store.load();
    return doc.entries.where((e) => e.userId == userId).toList();
  }

  @override
  Future<HabitEntry?> getEntryForDate(
    String userId,
    String habitId,
    String dateKey,
  ) async {
    final doc = await store.load();
    try {
      return doc.entries.firstWhere(
        (e) =>
            e.userId == userId && e.habitId == habitId && e.dateKey == dateKey,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<HabitEntry> saveEntry(String userId, HabitEntry entry) async {
    if (entry.userId != userId) {
      throw StateError('Yetkisiz işlem: Giriş kaydı bu kullanıcıya ait değil.');
    }
    final doc = await store.load();
    final updatedEntries = List<HabitEntry>.from(doc.entries);
    final index = updatedEntries.indexWhere(
      (e) =>
          e.userId == userId &&
          e.habitId == entry.habitId &&
          e.dateKey == entry.dateKey,
    );

    if (index >= 0) {
      updatedEntries[index] = entry;
    } else {
      updatedEntries.add(entry);
    }

    final updated = doc.copyWith(entries: updatedEntries);
    await store.save(updated);
    return entry;
  }

  @override
  Future<List<Achievement>> getAchievements(String userId) async {
    final doc = await store.load();
    return doc.achievements.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> saveAchievements(
    String userId,
    List<Achievement> achievements,
  ) async {
    final doc = await store.load();
    final updatedAchievements = List<Achievement>.from(doc.achievements);
    for (final ach in achievements) {
      if (ach.userId != userId) continue;
      final exists = updatedAchievements.any(
        (a) =>
            a.userId == userId &&
            a.type == ach.type &&
            a.habitId == ach.habitId,
      );
      if (!exists) {
        updatedAchievements.add(ach);
      }
    }
    final updated = doc.copyWith(achievements: updatedAchievements);
    await store.save(updated);
  }

  @override
  Future<void> removeAchievements(
    String userId,
    List<String> achievementIds,
  ) async {
    final doc = await store.load();
    final updatedAchievements = doc.achievements
        .where((a) => !(a.userId == userId && achievementIds.contains(a.id)))
        .toList();

    final updated = doc.copyWith(achievements: updatedAchievements);
    await store.save(updated);
  }

  @override
  Future<List<HabitReminder>> getReminders(String userId) async {
    final doc = await store.load();
    return doc.reminders.where((r) => r.userId == userId).toList();
  }

  @override
  Future<void> saveReminders(
    String userId,
    List<HabitReminder> reminders,
  ) async {
    final doc = await store.load();
    final updatedReminders = List<HabitReminder>.from(doc.reminders);
    for (final r in reminders) {
      if (r.userId != userId) continue;
      final exists = updatedReminders.any((old) => old.id == r.id);
      if (!exists) {
        updatedReminders.add(r);
      }
    }
    final updated = doc.copyWith(reminders: updatedReminders);
    await store.save(updated);
  }

  @override
  Future<void> markReminderAsRead(String userId, String reminderId) async {
    final doc = await store.load();
    final updatedReminders = doc.reminders.map((r) {
      if (r.userId == userId && r.id == reminderId) {
        return r.copyWith(isRead: true);
      }
      return r;
    }).toList();

    final updated = doc.copyWith(reminders: updatedReminders);
    await store.save(updated);
  }
}
