import 'package:flutter_test/flutter_test.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_entry.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';
import 'package:aliskanlik_takibi/features/habits/services/streak_service.dart';

void main() {
  group('StreakService Testleri', () {
    late StreakService streakService;

    setUp(() {
      streakService = StreakService();
    });

    test('3 gün üst üste tamamlanan her günlük görevde seri 3 olur', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Her Günlük Görev',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-18T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's1',
            habitId: 'h1',
            intervalDays: 1,
            anchorDateKey: '2026-10-18',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-18',
          ),
        ],
      );

      final entries = [
        const HabitEntry(
          id: 'e1',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-18',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-18T10:00:00Z',
          updatedAtUtc: '2026-10-18T10:00:00Z',
        ),
        const HabitEntry(
          id: 'e2',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-19',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-19T10:00:00Z',
          updatedAtUtc: '2026-10-19T10:00:00Z',
        ),
        const HabitEntry(
          id: 'e3',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-20',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-20T10:00:00Z',
          updatedAtUtc: '2026-10-20T10:00:00Z',
        ),
      ];

      // 4. gün henüz sabah ve görev tamamlanmadı -> Seri hâlâ 3 olmalı
      final streakMorning = streakService.calculateActiveStreak(
        habit: habit,
        entries: entries,
        todayKey: '2026-10-21',
      );
      expect(streakMorning, equals(3));

      // 4. gün tamamlandığında -> Seri 4 olmalı
      final entriesWithToday = [
        ...entries,
        const HabitEntry(
          id: 'e4',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-21',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-21T10:00:00Z',
          updatedAtUtc: '2026-10-21T10:00:00Z',
        ),
      ];

      final streakCompleted = streakService.calculateActiveStreak(
        habit: habit,
        entries: entriesWithToday,
        todayKey: '2026-10-21',
      );
      expect(streakCompleted, equals(4));
    });

    test('Son kapanan gün kaçırıldıysa aktif seri 0 olur', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Her Günlük',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-18T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's1',
            habitId: 'h1',
            intervalDays: 1,
            anchorDateKey: '2026-10-18',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-18',
          ),
        ],
      );

      // 18 ve 19 tamamlandı, 20 Ekim kaçırıldı, bugün 21 Ekim
      final entries = [
        const HabitEntry(
          id: 'e1',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-18',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-18T10:00:00Z',
          updatedAtUtc: '2026-10-18T10:00:00Z',
        ),
        const HabitEntry(
          id: 'e2',
          userId: 'u1',
          habitId: 'h1',
          scheduleId: 's1',
          dateKey: '2026-10-19',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-19T10:00:00Z',
          updatedAtUtc: '2026-10-19T10:00:00Z',
        ),
      ];

      final streak = streakService.calculateActiveStreak(
        habit: habit,
        entries: entries,
        todayKey: '2026-10-21',
      );
      expect(streak, equals(0));
    });

    test('2 günde bir olan görevde ara dinlenme günleri seriyi bozmaz', () {
      final habit = Habit(
        id: 'h2',
        userId: 'u1',
        title: '2 Günde Bir Görev',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-17T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's2',
            habitId: 'h2',
            intervalDays: 2,
            anchorDateKey: '2026-10-17',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-17',
          ),
        ],
      );

      // 17, 19 ve 21 Ekim tamamlandı. 18 ve 20 Ekim ara gün.
      final entries = [
        const HabitEntry(
          id: 'e1',
          userId: 'u1',
          habitId: 'h2',
          scheduleId: 's2',
          dateKey: '2026-10-17',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-17T10:00:00Z',
          updatedAtUtc: '2026-10-17T10:00:00Z',
        ),
        const HabitEntry(
          id: 'e2',
          userId: 'u1',
          habitId: 'h2',
          scheduleId: 's2',
          dateKey: '2026-10-19',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-19T10:00:00Z',
          updatedAtUtc: '2026-10-19T10:00:00Z',
        ),
        const HabitEntry(
          id: 'e3',
          userId: 'u1',
          habitId: 'h2',
          scheduleId: 's2',
          dateKey: '2026-10-21',
          progressValue: 1,
          targetValue: 1,
          completedAtUtc: '2026-10-21T10:00:00Z',
          updatedAtUtc: '2026-10-21T10:00:00Z',
        ),
      ];

      // 21 Ekim'de seri 3 olmalı
      final streakToday = streakService.calculateActiveStreak(
        habit: habit,
        entries: entries,
        todayKey: '2026-10-21',
      );
      expect(streakToday, equals(3));

      // 22 Ekim (ara gün, planlı değil) serisi de 3 olarak korunmalıdır!
      final streakRestDay = streakService.calculateActiveStreak(
        habit: habit,
        entries: entries,
        todayKey: '2026-10-22',
      );
      expect(streakRestDay, equals(3));
    });
  });
}
