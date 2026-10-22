import 'package:flutter_test/flutter_test.dart';

import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';
import 'package:aliskanlik_takibi/data/models/motivation_preferences.dart';
import 'package:aliskanlik_takibi/data/motivation/local_motivation_messages.dart';
import 'package:aliskanlik_takibi/data/motivation/motivation_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';
import 'package:aliskanlik_takibi/features/motivation/completion_feedback_controller.dart';
import 'package:aliskanlik_takibi/features/motivation/motivation_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('Yerel Motivasyon Havuzu Testleri', () {
    test('En az 20 adet genel motivasyon cümlesi bulunur', () {
      expect(
        LocalMotivationMessages.generalMessages.length,
        greaterThanOrEqualTo(20),
      );
      for (final msg in LocalMotivationMessages.generalMessages) {
        expect(msg.text.isNotEmpty, isTrue);
        expect(msg.text.length, lessThanOrEqualTo(120));
      }
    });

    test('Tamamlama kutlama cümleleri mevcuttur', () {
      expect(
        LocalMotivationMessages.completionMessages.length,
        greaterThanOrEqualTo(5),
      );
    });
  });

  group('Motivasyon Controller ve Tercih Testleri', () {
    test('Tercihler kaydedilir ve güncellenir', () async {
      final store = LocalStore();
      final habitRepo = LocalHabitRepository(store: store);
      final motRepo = MotivationRepository(habitRepository: habitRepo);
      final motCtrl = MotivationController(repository: motRepo);

      await motCtrl.initUser('user_test_1');
      expect(motCtrl.isMascotEnabled, isTrue);
      expect(motCtrl.preferences.intervalMinutes, 5);

      // Tercihleri güncelle
      await motCtrl.updatePreferences(
        const MotivationPreferences(
          userId: 'user_test_1',
          mascotEnabled: true,
          intervalMinutes: 10,
          completionFeedbackMode: 'sparkle',
          remoteSourceEnabled: false,
        ),
      );

      expect(motCtrl.preferences.intervalMinutes, 10);
      expect(motCtrl.preferences.completionFeedbackMode, 'sparkle');

      // Kalıcılık kontrolü
      final savedPrefs = await habitRepo.getMotivationPreferences(
        'user_test_1',
      );
      expect(savedPrefs.intervalMinutes, 10);
      expect(savedPrefs.completionFeedbackMode, 'sparkle');

      motCtrl.clear();
    });

    test(
      'Maskota dokunulduğunda yeni cümle balonda gösterilir ve kapatılabilir',
      () async {
        final store = LocalStore();
        final habitRepo = LocalHabitRepository(store: store);
        final motRepo = MotivationRepository(habitRepository: habitRepo);
        final motCtrl = MotivationController(repository: motRepo);

        await motCtrl.initUser('user_test_2');

        expect(motCtrl.isBubbleVisible, isFalse);
        motCtrl.onMascotTapped();
        expect(motCtrl.isBubbleVisible, isTrue);
        expect(motCtrl.currentMessageText, isNotNull);

        motCtrl.dismissBubble();
        expect(motCtrl.isBubbleVisible, isFalse);

        motCtrl.clear();
      },
    );
  });

  group('Görev Tamamlama Kutlama Mantığı Testleri', () {
    test('İlk tamamlamada kutlama tetiklenir, geri alınıp tekrar tamamlanınca tekrarlanmaz', () async {
      final store = LocalStore();
      final habitRepo = LocalHabitRepository(store: store);
      final motRepo = MotivationRepository(habitRepository: habitRepo);
      final motCtrl = MotivationController(repository: motRepo);
      final feedbackCtrl = CompletionFeedbackController(
        motivationRepository: motRepo,
        motivationController: motCtrl,
      );
      final habitCtrl = HabitController(repository: habitRepo);

      var celebrationCount = 0;
      habitCtrl.onHabitCelebration = ({required habit, required todayKey}) {
        celebrationCount++;
        feedbackCtrl.triggerCelebration(
          mode: 'message',
          habitTitle: habit.title,
        );
      };

      const userId = 'user_test_celeb';
      const todayKey = '2026-10-22';

      final habit = Habit(
        id: 'h_test_celeb',
        userId: userId,
        title: 'Kitap Oku',
        iconCodePoint: 1,
        colorValue: 0xFF3B6E52,
        createdAtUtc: '2026-10-22T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's_test_celeb',
            habitId: 'h_test_celeb',
            intervalDays: 1,
            anchorDateKey: todayKey,
            effectiveFromDateKey: todayKey,
            counterType: 'check',
            targetValue: 1,
          ),
        ],
      );

      await habitRepo.saveHabit(userId, habit);
      await habitCtrl.loadUserData(userId, todayKey);

      // 1. İLK TAMAMLAMA
      await habitCtrl.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      expect(celebrationCount, 1);
      expect(feedbackCtrl.isCelebrating, isTrue);
      expect(feedbackCtrl.activeCelebration, CelebrationType.message);

      // 2. GERİ ALMA (UNDO)
      await habitCtrl.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      final entryAfterUndo = habitCtrl.getEntry(habit.id, todayKey);
      expect(entryAfterUndo?.isCompleted, isFalse);
      // celebrationShownAtUtc silinmemelidir!
      expect(entryAfterUndo?.celebrationShownAtUtc, isNotNull);

      // 3. AYNI GÜN YENİDEN TAMAMLAMA (Kutlama tekrar etmemelidir!)
      await habitCtrl.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      expect(
        celebrationCount,
        1,
        reason: 'Aynı görev için aynı gün 2. kez kutlama tetiklenmemelidir.',
      );

      motCtrl.clear();
      feedbackCtrl.dispose();
    });
  });
}
