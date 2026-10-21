import '../../../core/time/date_key.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import '../habits/services/schedule_service.dart';
import '../habits/services/streak_service.dart';

class DayStat {
  final String dateKey;
  final String label; // "Pzt", "Sal" vb.
  final int scheduledCount;
  final int completedCount;
  final double ratio;

  const DayStat({
    required this.dateKey,
    required this.label,
    required this.scheduledCount,
    required this.completedCount,
    required this.ratio,
  });
}

class PeriodStatResult {
  final int totalScheduled;
  final int totalCompleted;
  final int completionPercentage;
  final String periodDescription;

  const PeriodStatResult({
    required this.totalScheduled,
    required this.totalCompleted,
    required this.completionPercentage,
    required this.periodDescription,
  });
}

class StatisticsService {
  final ScheduleService _scheduleService;
  final StreakService _streakService;

  StatisticsService({
    ScheduleService? scheduleService,
    StreakService? streakService,
  }) : _scheduleService = scheduleService ?? ScheduleService(),
       _streakService = streakService ?? StreakService();

  /// Seçili periyot için (hafta veya ay) tamamlama istatistiklerini hesaplar.
  /// 6.4.9: Gelecek günler paydaya katılmaz.
  PeriodStatResult calculatePeriodStats({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required String todayKey,
    required bool isWeekly, // true = Bu Hafta, false = Bu Ay
  }) {
    final todayDt = DateKey(todayKey).toDateTimeUtc();
    String startDateKey;

    if (isWeekly) {
      // Hafta Pazartesi başlar (weekday 1 = Pazartesi)
      final mondayOffset = todayDt.weekday - 1;
      final monday = todayDt.subtract(Duration(days: mondayOffset));
      startDateKey = DateKey.fromDate(monday).value;
    } else {
      // Takvim ayının ilk günü
      final firstDay = DateTime.utc(todayDt.year, todayDt.month, 1);
      startDateKey = DateKey.fromDate(firstDay).value;
    }

    // startDateKey'den todayKey'e kadar olan günleri tara
    var totalScheduled = 0;
    var totalCompleted = 0;

    var cur = startDateKey;
    while (cur.compareTo(todayKey) <= 0) {
      final entriesOnDay = entries.where((e) => e.dateKey == cur).toList();
      for (final h in habits) {
        final isScheduled = _scheduleService.isHabitScheduledOnDate(
          habit: h,
          dateKey: cur,
          isCompletedOnDate: entriesOnDay.any(
            (e) => e.habitId == h.id && e.isCompleted,
          ),
        );
        if (isScheduled) {
          totalScheduled++;
          final completed = entriesOnDay.any(
            (e) => e.habitId == h.id && e.isCompleted,
          );
          if (completed) {
            totalCompleted++;
          }
        }
      }
      cur = DateKey.addDays(cur, 1);
    }

    final percentage = totalScheduled == 0
        ? 0
        : ((totalCompleted / totalScheduled) * 100).round();

    return PeriodStatResult(
      totalScheduled: totalScheduled,
      totalCompleted: totalCompleted,
      completionPercentage: percentage,
      periodDescription: totalScheduled == 0
          ? 'Bu dönemde planlı görev yok.'
          : '',
    );
  }

  /// Son 7 günün günlük başarı grafiği verilerini döner.
  List<DayStat> get7DayStats({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required String todayKey,
  }) {
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final result = <DayStat>[];

    for (var i = 6; i >= 0; i--) {
      final dKey = DateKey.addDays(todayKey, -i);
      final dt = DateKey(dKey).toDateTimeUtc();
      final dayLabel = dayNames[dt.weekday - 1];

      final entriesOnDay = entries.where((e) => e.dateKey == dKey).toList();
      var scheduled = 0;
      var completed = 0;

      for (final h in habits) {
        final isComp = entriesOnDay.any(
          (e) => e.habitId == h.id && e.isCompleted,
        );
        final isSched = _scheduleService.isHabitScheduledOnDate(
          habit: h,
          dateKey: dKey,
          isCompletedOnDate: isComp,
        );
        if (isSched) {
          scheduled++;
          if (isComp) completed++;
        }
      }

      final ratio = scheduled == 0
          ? 0.0
          : (completed / scheduled).clamp(0.0, 1.0);
      result.add(
        DayStat(
          dateKey: dKey,
          label: dayLabel,
          scheduledCount: scheduled,
          completedCount: completed,
          ratio: ratio,
        ),
      );
    }

    return result;
  }

  /// Tüm zamanların en yüksek rekorunu ve sahibini bulur.
  ({int streak, String habitTitle, String? achievedDateKey})
  getOverallBestRecord({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required String todayKey,
  }) {
    var maxStreak = 0;
    var maxTitle = '';
    String? bestDate;

    for (final h in habits) {
      final best = _streakService.calculateBestStreak(
        habit: h,
        entries: entries,
        todayKey: todayKey,
      );
      if (best.streak > maxStreak) {
        maxStreak = best.streak;
        maxTitle = h.title;
        bestDate = best.achievedDateKey;
      }
    }

    return (streak: maxStreak, habitTitle: maxTitle, achievedDateKey: bestDate);
  }
}
