import '../../../data/models/habit.dart';
import '../../../data/models/habit_reminder.dart';
import '../habits/services/schedule_service.dart';

class ReminderService {
  final ScheduleService _scheduleService;

  ReminderService({ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService();

  /// Bugün planlı olan ve hatırlatması açık alışkanlıklar için uygulama içi hatırlatma üretir.
  /// 6.2.13 & 6.4:
  /// - Hatırlatma hedef saatinden 1 saat öncedir.
  /// - Hatırlatmalar yalnızca uygulama içinde çalışır, işletim sistemi bildirimi iddiasında bulunulmaz.
  List<HabitReminder> generateInAppReminders({
    required String userId,
    required List<Habit> habits,
    required String todayKey,
    required DateTime now,
    required List<HabitReminder> existingReminders,
  }) {
    final result = <HabitReminder>[];
    final existingIds = existingReminders.map((r) => r.id).toSet();

    for (final habit in habits) {
      if (habit.userId != userId || habit.isArchived) continue;
      final schedule = habit.latestSchedule;
      if (!schedule.reminderEnabled) continue;

      final isScheduled = _scheduleService.isHabitScheduledOnDate(
        habit: habit,
        dateKey: todayKey,
      );
      if (!isScheduled) continue;

      // Hedef saatini ayrıştır (HH:mm)
      final parts = schedule.targetTime.split(':');
      if (parts.length != 2) continue;
      final targetHour = int.tryParse(parts[0]) ?? 21;
      final targetMinute = int.tryParse(parts[1]) ?? 0;

      // 1 saat öncesi
      var reminderHour = targetHour - 1;
      if (reminderHour < 0) {
        reminderHour = 23; // Önceki güne düşer
      }
      final reminderTimeStr =
          '${reminderHour.toString().padLeft(2, '0')}:${targetMinute.toString().padLeft(2, '0')}';

      final reminderId = 'rem_${habit.id}_$todayKey';
      if (!existingIds.contains(reminderId)) {
        result.add(
          HabitReminder(
            id: reminderId,
            userId: userId,
            habitId: habit.id,
            habitTitle: habit.title,
            dateKey: todayKey,
            reminderTime: reminderTimeStr,
            isRead: false,
            createdAtUtc: now.toUtc().toIso8601String(),
            message:
                '${habit.title} için hedef saat yaklaşıyor! (Günlük hedef: ${schedule.targetTime})',
          ),
        );
      }
    }

    return result;
  }
}
