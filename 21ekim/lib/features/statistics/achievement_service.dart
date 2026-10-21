import '../../../data/models/achievement.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import '../habits/services/streak_service.dart';

class AchievementService {
  final StreakService _streakService;

  AchievementService({StreakService? streakService})
    : _streakService = streakService ?? StreakService();

  /// Kullanıcının mevcut alışkanlıkları ve kayıtlarına göre kazanılan rozetleri hesaplar.
  /// 6.4.6 kuralları:
  /// - 10: Bronz Başlangıç
  /// - 25: Gümüş Devamlılık
  /// - 50: Altın İstikrar
  /// - Her alışkanlığın en yüksek rekoruna bakılır.
  List<Achievement> evaluateAchievements({
    required String userId,
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required String todayKey,
    required List<Achievement> existingAchievements,
  }) {
    final result = List<Achievement>.from(existingAchievements);

    for (final habit in habits) {
      if (habit.userId != userId) continue;
      final best = _streakService.calculateBestStreak(
        habit: habit,
        entries: entries,
        todayKey: todayKey,
      );

      final thresholds = [
        (threshold: 10, type: 'bronze', title: 'Bronz Başlangıç'),
        (threshold: 25, type: 'silver', title: 'Gümüş Devamlılık'),
        (threshold: 50, type: 'gold', title: 'Altın İstikrar'),
      ];

      for (final t in thresholds) {
        if (best.streak >= t.threshold) {
          final alreadyHas = result.any(
            (a) =>
                a.userId == userId && a.type == t.type && a.habitId == habit.id,
          );
          if (!alreadyHas) {
            result.add(
              Achievement(
                id: 'ach_${t.type}_${habit.id}',
                userId: userId,
                type: t.type,
                title: t.title,
                threshold: t.threshold,
                habitId: habit.id,
                habitTitle: habit.title,
                unlockedDateKey: best.achievedDateKey ?? todayKey,
                unlockedAtUtc: DateTime.now().toUtc().toIso8601String(),
              ),
            );
          }
        }
      }
    }

    return result;
  }

  /// Aynı gün geri alma işlemi sonrası, eğer o rozeti sağlayan tek seri ortadan kalktıysa
  /// rozetin geri alınmasını sağlar (6.4.6).
  List<String> findInvalidatedAchievements({
    required String userId,
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required String todayKey,
    required List<Achievement> currentAchievements,
  }) {
    final toRemove = <String>[];

    for (final ach in currentAchievements) {
      if (ach.userId != userId) continue;
      final habit = habits.firstWhere(
        (h) => h.id == ach.habitId,
        orElse: () => Habit(
          id: ach.habitId,
          userId: userId,
          title: ach.habitTitle,
          iconCodePoint: 0,
          colorValue: 0,
          createdAtUtc: '',
          schedules: [],
        ),
      );
      if (habit.schedules.isEmpty) continue;

      final best = _streakService.calculateBestStreak(
        habit: habit,
        entries: entries,
        todayKey: todayKey,
      );

      if (best.streak < ach.threshold) {
        toRemove.add(ach.id);
      }
    }

    return toRemove;
  }
}
