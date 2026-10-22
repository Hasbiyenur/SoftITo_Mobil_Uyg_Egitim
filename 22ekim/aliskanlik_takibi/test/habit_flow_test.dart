import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';

void main() {
  group('HabitController Akış Testleri', () {
    late LocalStore store;
    late LocalHabitRepository repository;
    late HabitController controller;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      store = LocalStore();
      repository = LocalHabitRepository(store: store);
      controller = HabitController(repository: repository);
    });

    test('Tik atma ve aynı gün geri alma (undo) akışı', () async {
      const userId = 'user_test';
      const todayKey = '2026-10-21';

      final habit = Habit(
        id: 'h_test_1',
        userId: userId,
        title: 'Su İç',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-21T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's_test_1',
            habitId: 'h_test_1',
            intervalDays: 1,
            anchorDateKey: todayKey,
            counterType: 'check',
            targetValue: 1,
            effectiveFromDateKey: todayKey,
          ),
        ],
      );

      await repository.saveHabit(userId, habit);
      await controller.loadUserData(userId, todayKey);

      // 1. Başlangıçta tamamlanmamış olmalı
      expect(controller.isCompletedOnDate(habit.id, todayKey), isFalse);
      expect(controller.getTodayTodoHabits(todayKey).length, equals(1));
      expect(controller.getTodayDoneHabits(todayKey).length, equals(0));

      // 2. Tik at (Tamamla)
      await controller.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      expect(controller.isCompletedOnDate(habit.id, todayKey), isTrue);
      expect(controller.getTodayTodoHabits(todayKey).length, equals(0));
      expect(controller.getTodayDoneHabits(todayKey).length, equals(1));

      // 3. Tekrar tıkla (Geri al)
      await controller.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      expect(controller.isCompletedOnDate(habit.id, todayKey), isFalse);
      expect(controller.getTodayTodoHabits(todayKey).length, equals(1));
      expect(controller.getTodayDoneHabits(todayKey).length, equals(0));
    });

    test('Miktar sayacı artırma, hedefe ulaşma ve azaltma akışı', () async {
      const userId = 'user_test';
      const todayKey = '2026-10-21';

      final habit = Habit(
        id: 'h_counter_1',
        userId: userId,
        title: 'Sayfa Oku',
        iconCodePoint: 1,
        colorValue: 0xFFFFFFFF,
        createdAtUtc: '2026-10-21T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's_counter_1',
            habitId: 'h_counter_1',
            intervalDays: 1,
            anchorDateKey: todayKey,
            counterType: 'counter',
            targetValue: 10,
            step: 5,
            unit: 'sayfa',
            effectiveFromDateKey: todayKey,
          ),
        ],
      );

      await repository.saveHabit(userId, habit);
      await controller.loadUserData(userId, todayKey);

      // 1. Adım: 5 sayfa oku (+5)
      await controller.incrementCounter(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );
      var entry = controller.getEntry(habit.id, todayKey);
      expect(entry?.progressValue, equals(5));
      expect(entry?.isCompleted, isFalse);

      // 2. Adım: 5 sayfa daha oku (+5) -> 10'a ulaştı, tamamlandı
      await controller.incrementCounter(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );
      entry = controller.getEntry(habit.id, todayKey);
      expect(entry?.progressValue, equals(10));
      expect(entry?.isCompleted, isTrue);

      // 3. Adım: Azalt (-5) -> 5'e düştü, tamamlanma geri alındı
      await controller.decrementCounter(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );
      entry = controller.getEntry(habit.id, todayKey);
      expect(entry?.progressValue, equals(5));
      expect(entry?.isCompleted, isFalse);
    });

    test(
      'Alışkanlık mantıksal olarak kaldırıldığında geçmiş kayıtlar korunur',
      () async {
        const userId = 'user_test';
        const todayKey = '2026-10-21';

        final habit = Habit(
          id: 'h_del_1',
          userId: userId,
          title: 'Eski Alışkanlık',
          iconCodePoint: 1,
          colorValue: 0xFFFFFFFF,
          createdAtUtc: '2026-10-21T00:00:00Z',
          schedules: [
            const HabitSchedule(
              id: 's_del_1',
              habitId: 'h_del_1',
              intervalDays: 1,
              anchorDateKey: todayKey,
              counterType: 'check',
              targetValue: 1,
              effectiveFromDateKey: todayKey,
            ),
          ],
        );

        await repository.saveHabit(userId, habit);
        await controller.loadUserData(userId, todayKey);

        // Görevi tamamla
        await controller.toggleCheck(
          userId: userId,
          habit: habit,
          todayKey: todayKey,
        );
        expect(controller.entries.length, equals(1));

        // Görevi kaldır
        await controller.archiveHabits(
          userId: userId,
          habitIds: [habit.id],
          todayKey: todayKey,
        );

        // Aktif listeden çıkmış olmalı
        expect(controller.activeHabits.any((h) => h.id == habit.id), isFalse);

        // Ancak allHabits içinde arşivlenmiş olarak bulunmalı ve kayıtları silinmemeli
        expect(controller.allHabits.any((h) => h.id == habit.id), isTrue);
        expect(controller.entries.length, equals(1));
      },
    );
  });
}
