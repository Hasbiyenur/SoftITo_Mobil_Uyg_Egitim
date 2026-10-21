import '../../../core/time/date_key.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_schedule.dart';

class ScheduleService {
  /// Bir alışkanlığın verilen [dateKey] ("yyyy-MM-dd") tarihinde planlı olup olmadığını hesaplar.
  /// 6.4.1 kuralları:
  /// 1. İstenen tarih için geçerli HabitSchedule sürümünü bulur.
  /// 2. Tarih anchorDateKey'den önceyse planlı değildir.
  /// 3. Gün farkı UTC takvim günleri arasında hesaplanır.
  /// 4. gunFarki % intervalDays == 0 ise o gün planlıdır.
  /// 5. Görev kaldırılmışsa ve dateKey kaldırma gününden sonraysa planlı değildir.
  bool isHabitScheduledOnDate({
    required Habit habit,
    required String dateKey,
    bool isCompletedOnDate = false,
  }) {
    // 6.4.8: Kaldırma gününden sonraki tarihlerde yeni tekrar oluşmaz.
    if (habit.isArchived && habit.archivedOnDateKey != null) {
      if (dateKey.compareTo(habit.archivedOnDateKey!) > 0) {
        return false;
      }
      // Kaldırıldığı gün tamamlanmamışsa iptal edilmiş sayılır
      if (dateKey == habit.archivedOnDateKey && !isCompletedOnDate) {
        return false;
      }
    }

    final schedule = habit.activeScheduleForDate(dateKey);
    final daysDiff = DateKey.daysBetween(schedule.anchorDateKey, dateKey);

    if (daysDiff < 0) {
      return false;
    }

    return daysDiff % schedule.intervalDays == 0;
  }

  /// Verilen plandan ve başlangıç tarihinden itibaren sonraki [count] planlı takvim gününü döner.
  List<String> getNextScheduledDates(
    HabitSchedule schedule,
    String fromDateKey, {
    int count = 3,
  }) {
    final result = <String>[];
    var currentKey = fromDateKey;

    // Eğer fromDateKey anchor'dan önceyse anchor'a atla
    if (DateKey.daysBetween(schedule.anchorDateKey, currentKey) < 0) {
      currentKey = schedule.anchorDateKey;
    }

    // currentKey'den başlayarak gün gün tara
    var safety = 0;
    while (result.length < count && safety < 1000) {
      safety++;
      final diff = DateKey.daysBetween(schedule.anchorDateKey, currentKey);
      if (diff >= 0 && diff % schedule.intervalDays == 0) {
        result.add(currentKey);
      }
      currentKey = DateKey.addDays(currentKey, 1);
    }

    return result;
  }
}
