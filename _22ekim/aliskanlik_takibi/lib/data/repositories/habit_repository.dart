import '../models/achievement.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../models/habit_reminder.dart';
import '../models/motivation_preferences.dart';
import '../models/motivation_message.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits(String userId);
  Future<Habit?> getHabitById(String userId, String habitId);
  Future<void> saveHabit(String userId, Habit habit);
  Future<void> archiveHabits(
    String userId,
    List<String> habitIds,
    String todayKey,
  );

  Future<List<HabitEntry>> getEntries(String userId);
  Future<HabitEntry?> getEntryForDate(
    String userId,
    String habitId,
    String dateKey,
  );
  Future<HabitEntry> saveEntry(String userId, HabitEntry entry);

  Future<List<Achievement>> getAchievements(String userId);
  Future<void> saveAchievements(String userId, List<Achievement> achievements);
  Future<void> removeAchievements(String userId, List<String> achievementIds);

  Future<List<HabitReminder>> getReminders(String userId);
  Future<void> saveReminders(String userId, List<HabitReminder> reminders);
  Future<void> markReminderAsRead(String userId, String reminderId);

  Future<MotivationPreferences> getMotivationPreferences(String userId);
  Future<void> saveMotivationPreferences(
    String userId,
    MotivationPreferences preferences,
  );
  Future<List<MotivationMessage>> getMotivationCache();
  Future<void> saveMotivationCache(
    List<MotivationMessage> messages,
    String? fetchedAtUtc,
  );
}
