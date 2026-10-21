import '../../../core/time/date_key.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import 'schedule_service.dart';

class BestStreakInfo {
  final int streak;
  final String? achievedDateKey;

  const BestStreakInfo({required this.streak, this.achievedDateKey});
}

class StreakService {
  final ScheduleService _scheduleService;

  StreakService({ScheduleService? scheduleService})
    : _scheduleService = scheduleService ?? ScheduleService();

  /// Belirli bir alışkanlık için [todayKey] anındaki aktif streak değerini hesaplar.
  int calculateActiveStreak({
    required Habit habit,
    required List<HabitEntry> entries,
    required String todayKey,
  }) {
    final schedule = habit.latestSchedule;
    final scheduledDates = _getScheduledDatesUpTo(
      habit: habit,
      fromDateKey: schedule.anchorDateKey,
      toDateKey: todayKey,
    );

    if (scheduledDates.isEmpty) return 0;

    // Tamamlanan günleri Set'e topla
    final completedDateSet = entries
        .where((e) => e.habitId == habit.id && e.isCompleted)
        .map((e) => e.dateKey)
        .toSet();

    final isTodayScheduled = scheduledDates.last == todayKey;

    if (isTodayScheduled) {
      final isTodayCompleted = completedDateSet.contains(todayKey);
      if (isTodayCompleted) {
        // Bugün tamamlandı, bugünden geriye doğru say
        var streak = 0;
        for (var i = scheduledDates.length - 1; i >= 0; i--) {
          if (completedDateSet.contains(scheduledDates[i])) {
            streak++;
          } else {
            break;
          }
        }
        return streak;
      } else {
        // Bugün henüz tamamlanmadı ve gün kapanmadı: Seri sıfırlanmaz,
        // dünden (önceki planlı günden) geriye doğru sayılır.
        if (scheduledDates.length < 2) return 0;
        final lastClosedDate = scheduledDates[scheduledDates.length - 2];
        if (!completedDateSet.contains(lastClosedDate)) {
          return 0; // Son kapanmış gün kaçırılmış, seri 0
        }
        var streak = 0;
        for (var i = scheduledDates.length - 2; i >= 0; i--) {
          if (completedDateSet.contains(scheduledDates[i])) {
            streak++;
          } else {
            break;
          }
        }
        return streak;
      }
    } else {
      // Bugün planlı değil: Son planlı günün serisi korunur
      final lastClosedDate = scheduledDates.last;
      if (!completedDateSet.contains(lastClosedDate)) {
        return 0;
      }
      var streak = 0;
      for (var i = scheduledDates.length - 1; i >= 0; i--) {
        if (completedDateSet.contains(scheduledDates[i])) {
          streak++;
        } else {
          break;
        }
      }
      return streak;
    }
  }

  /// Bir alışkanlığın tüm zamanlardaki en uzun kesintisiz planlı gün serisini ve ilk elde edildiği tarihi bulur.
  BestStreakInfo calculateBestStreak({
    required Habit habit,
    required List<HabitEntry> entries,
    required String todayKey,
  }) {
    // Alışkanlığın ilk başlangıcından bugüne kadar tüm planlı günleri tara
    final initialSchedule = habit.schedules.first;
    final scheduledDates = _getScheduledDatesUpTo(
      habit: habit,
      fromDateKey: initialSchedule.anchorDateKey,
      toDateKey: todayKey,
    );

    if (scheduledDates.isEmpty) {
      return const BestStreakInfo(streak: 0, achievedDateKey: null);
    }

    final completedDateSet = entries
        .where((e) => e.habitId == habit.id && e.isCompleted)
        .map((e) => e.dateKey)
        .toSet();

    var currentStreak = 0;
    var maxStreak = 0;
    String? bestDateKey;

    for (final d in scheduledDates) {
      if (completedDateSet.contains(d)) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
          bestDateKey = d;
        }
      } else {
        currentStreak = 0;
      }
    }

    return BestStreakInfo(streak: maxStreak, achievedDateKey: bestDateKey);
  }

  List<String> _getScheduledDatesUpTo({
    required Habit habit,
    required String fromDateKey,
    required String toDateKey,
  }) {
    final result = <String>[];
    var current = fromDateKey;
    while (current.compareTo(toDateKey) <= 0) {
      if (_scheduleService.isHabitScheduledOnDate(
        habit: habit,
        dateKey: current,
      )) {
        result.add(current);
      }
      current = DateKey.addDays(current, 1);
    }
    return result;
  }
}
