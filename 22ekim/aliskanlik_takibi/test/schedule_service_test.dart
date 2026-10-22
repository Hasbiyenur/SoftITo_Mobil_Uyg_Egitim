import 'package:flutter_test/flutter_test.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';
import 'package:aliskanlik_takibi/features/habits/services/schedule_service.dart';

void main() {
  group('ScheduleService Testleri', () {
    late ScheduleService service;

    setUp(() {
      service = ScheduleService();
    });

    test('Her gün (interval = 1) olan alışkanlık tüm günlerde planlıdır', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Her Günlük',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-21T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's1',
            habitId: 'h1',
            intervalDays: 1,
            anchorDateKey: '2026-10-21',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-21',
          ),
        ],
      );

      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-21'),
        isTrue,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-22'),
        isTrue,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-23'),
        isTrue,
      );
      // Başlangıçtan önceki gün planlı olmamalıdır
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-20'),
        isFalse,
      );
    });

    test('2 günde bir olan alışkanlık aradaki günlerde planlı değildir', () {
      final habit = Habit(
        id: 'h2',
        userId: 'u1',
        title: '2 Günde Bir',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-21T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's2',
            habitId: 'h2',
            intervalDays: 2,
            anchorDateKey: '2026-10-21',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-21',
          ),
        ],
      );

      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-21'),
        isTrue,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-22'),
        isFalse,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-23'),
        isTrue,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-24'),
        isFalse,
      );
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-25'),
        isTrue,
      );
    });

    test('Kaldırılan görev kaldırma gününden sonra planlı değildir', () {
      final habit = Habit(
        id: 'h3',
        userId: 'u1',
        title: 'Kaldırılan Görev',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-20T00:00:00Z',
        archivedAtUtc: '2026-10-22T10:00:00Z',
        archivedOnDateKey: '2026-10-22',
        schedules: [
          const HabitSchedule(
            id: 's3',
            habitId: 'h3',
            intervalDays: 1,
            anchorDateKey: '2026-10-20',
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: '2026-10-20',
          ),
        ],
      );

      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-21'),
        isTrue,
      );
      // Kaldırma gününden sonraki gün planlı olamaz
      expect(
        service.isHabitScheduledOnDate(habit: habit, dateKey: '2026-10-23'),
        isFalse,
      );
    });

    test('Sonraki 3 planlı takvim günü doğru hesaplanır', () {
      const schedule = HabitSchedule(
        id: 's4',
        habitId: 'h4',
        intervalDays: 3,
        anchorDateKey: '2026-10-21',
        counterType: 'check',
        targetValue: 1,
        effectiveFromDateKey: '2026-10-21',
      );

      final next3 = service.getNextScheduledDates(
        schedule,
        '2026-10-21',
        count: 3,
      );
      expect(next3, equals(['2026-10-21', '2026-10-24', '2026-10-27']));
    });
  });
}
