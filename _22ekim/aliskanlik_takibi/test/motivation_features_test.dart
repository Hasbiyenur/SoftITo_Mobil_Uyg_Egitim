import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aliskanlik_takibi/core/theme/app_colors.dart';
import 'package:aliskanlik_takibi/core/theme/app_theme.dart';
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
    test('İlk tamamlamada ve geri alma sonrası yeniden tamamlamada kutlama efekti tetiklenir', () async {
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
      expect(feedbackCtrl.celebrationCounter, 1);

      // 2. GERİ ALMA (UNDO)
      await habitCtrl.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      final entryAfterUndo = habitCtrl.getEntry(habit.id, todayKey);
      expect(entryAfterUndo?.isCompleted, isFalse);
      expect(entryAfterUndo?.celebrationShownAtUtc, isNotNull);

      // 3. AYNI GÜN GERİ ALMA SONRASI YENİDEN TAMAMLAMA
      await habitCtrl.toggleCheck(
        userId: userId,
        habit: habit,
        todayKey: todayKey,
      );

      final entryAfterRecomplete = habitCtrl.getEntry(habit.id, todayKey);
      expect(entryAfterRecomplete?.isCompleted, isTrue);
      expect(entryAfterRecomplete?.completionRevision, 2);
      expect(
        celebrationCount,
        2,
        reason: 'Geri alınan görev tekrar tamamlandığında kutlama efekti tetiklenmelidir.',
      );
      expect(feedbackCtrl.celebrationCounter, 2);

      motCtrl.clear();
      feedbackCtrl.dispose();
    });
  });

  group('Koyu Tema Renk ve Kontrast Testleri', () {
    test('Koyu temada tüm sayfa ve kutucuklar koyu, yazılar açık renkte tanımlıdır', () {
      final dark = AppTheme.darkTheme;
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(dark.colorScheme.surface, AppColors.darkSurface);
      expect(dark.colorScheme.onSurface, AppColors.darkOnSurface);
      expect(dark.colorScheme.onSurfaceVariant, AppColors.darkOnSurfaceVariant);
      expect(dark.cardTheme.color, AppColors.darkSurface);
      expect(dark.dialogTheme.backgroundColor, AppColors.darkSurface);
      expect(dark.bottomSheetTheme.backgroundColor, AppColors.darkSurface);
      expect(dark.inputDecorationTheme.fillColor, AppColors.darkSurface);
      expect(dark.snackBarTheme.backgroundColor, AppColors.darkSurface);
      expect(
        dark.snackBarTheme.contentTextStyle?.color,
        AppColors.darkOnSurface,
      );
      expect(AppColors.darkCompletedText, const Color(0xFF8F9E95));
    });
  });
}
