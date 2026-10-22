import 'package:flutter/material.dart';

import '../../core/security/demo_password_service.dart';
import '../../core/storage/store_document.dart';
import '../../core/time/date_key.dart';
import '../models/app_user.dart';
import '../models/habit.dart';
import '../models/habit_schedule.dart';
import '../models/habit_entry.dart';
import '../models/achievement.dart';
import '../models/motivation_preferences.dart';

class DemoSeed {
  final DemoPasswordService _passwordService;

  DemoSeed({DemoPasswordService? passwordService})
    : _passwordService = passwordService ?? DemoPasswordService();

  Future<StoreDocument> applySeedIfNeeded(
    StoreDocument currentDoc,
    DateTime now,
  ) async {
    // Demo tohumu daha önce uygulanmışsa dokunma
    if (currentDoc.demoSeedVersion > 0 && currentDoc.users.isNotEmpty) {
      return currentDoc;
    }

    final salt = _passwordService.generateSalt();
    final hash = await _passwordService.hashPassword('demo1234', salt);
    final todayKey = DateKey.fromDate(now).value;

    const demoUserId = 'user_demo_default';
    final demoUser = AppUser(
      id: demoUserId,
      firstName: 'Hasbiyenur',
      lastName: 'Kaya',
      email: 'demo@aliskanlik.com',
      passwordSalt: salt,
      passwordHash: hash,
      createdAtUtc: now.toUtc().toIso8601String(),
    );

    // 1. Kitap Oku: 12 gün üst üste tamamlanmış (Bronz rozet)
    const habit1Id = 'habit_kitap_oku';
    const schedule1Id = 'sched_kitap_1';
    final habit1StartKey = DateKey.addDays(todayKey, -12);
    final habit1 = Habit(
      id: habit1Id,
      userId: demoUserId,
      title: 'Kitap Oku',
      description: 'Her gün en az 20 sayfa kitap okuma',
      iconCodePoint: Icons.menu_book_rounded.codePoint,
      colorValue: const Color(0xFF3B6E52).toARGB32(),
      createdAtUtc: now
          .subtract(const Duration(days: 13))
          .toUtc()
          .toIso8601String(),
      schedules: [
        HabitSchedule(
          id: schedule1Id,
          habitId: habit1Id,
          intervalDays: 1,
          anchorDateKey: habit1StartKey,
          counterType: 'counter',
          targetValue: 20,
          unit: 'sayfa',
          step: 5,
          targetTime: '21:00',
          reminderEnabled: true,
          effectiveFromDateKey: habit1StartKey,
        ),
      ],
    );

    // 2. Su İç: Bugün kısmi ilerleme (5/8 bardak, Yapılacaklar'da)
    const habit2Id = 'habit_su_ic';
    const schedule2Id = 'sched_su_1';
    final habit2StartKey = DateKey.addDays(todayKey, -5);
    final habit2 = Habit(
      id: habit2Id,
      userId: demoUserId,
      title: 'Su İç',
      description: 'Günlük su tüketimi',
      iconCodePoint: Icons.water_drop_rounded.codePoint,
      colorValue: const Color(0xFF4A7298).toARGB32(),
      createdAtUtc: now
          .subtract(const Duration(days: 6))
          .toUtc()
          .toIso8601String(),
      schedules: [
        HabitSchedule(
          id: schedule2Id,
          habitId: habit2Id,
          intervalDays: 1,
          anchorDateKey: habit2StartKey,
          counterType: 'counter',
          targetValue: 8,
          unit: 'bardak',
          step: 1,
          targetTime: '22:00',
          reminderEnabled: true,
          effectiveFromDateKey: habit2StartKey,
        ),
      ],
    );

    // 3. Yürüyüş Yap: Bugün tamamlanmış (Yapılanlar'da)
    const habit3Id = 'habit_yuruyus';
    const schedule3Id = 'sched_yuruyus_1';
    final habit3StartKey = DateKey.addDays(todayKey, -3);
    final habit3 = Habit(
      id: habit3Id,
      userId: demoUserId,
      title: 'Yürüyüş Yap',
      description: 'Temiz havada yürüyüş',
      iconCodePoint: Icons.directions_walk_rounded.codePoint,
      colorValue: const Color(0xFFD97757).toARGB32(),
      createdAtUtc: now
          .subtract(const Duration(days: 4))
          .toUtc()
          .toIso8601String(),
      schedules: [
        HabitSchedule(
          id: schedule3Id,
          habitId: habit3Id,
          intervalDays: 1,
          anchorDateKey: habit3StartKey,
          counterType: 'check',
          targetValue: 1,
          targetTime: '18:00',
          reminderEnabled: true,
          effectiveFromDateKey: habit3StartKey,
        ),
      ],
    );

    // 4. Ders Çalış: 2 günde bir, bugün planlı (Yapılacaklar'da)
    const habit4Id = 'habit_ders_calis';
    const schedule4Id = 'sched_ders_1';
    final habit4 = Habit(
      id: habit4Id,
      userId: demoUserId,
      title: 'Ders Çalış',
      description: 'Mobil uygulama geliştirme pratikleri',
      iconCodePoint: Icons.school_rounded.codePoint,
      colorValue: const Color(0xFF7C6DAF).toARGB32(),
      createdAtUtc: now
          .subtract(const Duration(days: 5))
          .toUtc()
          .toIso8601String(),
      schedules: [
        HabitSchedule(
          id: schedule4Id,
          habitId: habit4Id,
          intervalDays: 2,
          anchorDateKey: todayKey, // Bugün planlı
          counterType: 'check',
          targetValue: 1,
          targetTime: '20:00',
          reminderEnabled: true,
          effectiveFromDateKey: todayKey,
        ),
      ],
    );

    // Geçmiş tamamlama kayıtları
    final entries = <HabitEntry>[];

    // Kitap Oku: Son 12 gün tamamlandı (bugün dahil: 20 sayfa)
    for (var i = 0; i <= 12; i++) {
      final dKey = DateKey.addDays(todayKey, -i);
      entries.add(
        HabitEntry(
          id: 'entry_kitap_$dKey',
          userId: demoUserId,
          habitId: habit1Id,
          scheduleId: schedule1Id,
          dateKey: dKey,
          progressValue: 20,
          targetValue: 20,
          completedAtUtc: now
              .subtract(Duration(days: i, hours: 2))
              .toUtc()
              .toIso8601String(),
          updatedAtUtc: now
              .subtract(Duration(days: i, hours: 2))
              .toUtc()
              .toIso8601String(),
        ),
      );
    }

    // Su İç: Geçmiş 4 gün tamamlandı, bugün 5/8 (tamamlanmadı)
    for (var i = 1; i <= 4; i++) {
      final dKey = DateKey.addDays(todayKey, -i);
      entries.add(
        HabitEntry(
          id: 'entry_su_$dKey',
          userId: demoUserId,
          habitId: habit2Id,
          scheduleId: schedule2Id,
          dateKey: dKey,
          progressValue: 8,
          targetValue: 8,
          completedAtUtc: now
              .subtract(Duration(days: i, hours: 1))
              .toUtc()
              .toIso8601String(),
          updatedAtUtc: now
              .subtract(Duration(days: i, hours: 1))
              .toUtc()
              .toIso8601String(),
        ),
      );
    }
    // Su İç bugün:
    entries.add(
      HabitEntry(
        id: 'entry_su_$todayKey',
        userId: demoUserId,
        habitId: habit2Id,
        scheduleId: schedule2Id,
        dateKey: todayKey,
        progressValue: 5,
        targetValue: 8,
        completedAtUtc: null,
        updatedAtUtc: now.toUtc().toIso8601String(),
      ),
    );

    // Yürüyüş Yap: Bugün tamamlandı
    entries.add(
      HabitEntry(
        id: 'entry_yuruyus_$todayKey',
        userId: demoUserId,
        habitId: habit3Id,
        scheduleId: schedule3Id,
        dateKey: todayKey,
        progressValue: 1,
        targetValue: 1,
        completedAtUtc: now
            .subtract(const Duration(minutes: 45))
            .toUtc()
            .toIso8601String(),
        updatedAtUtc: now
            .subtract(const Duration(minutes: 45))
            .toUtc()
            .toIso8601String(),
      ),
    );

    // Başarı rozeti: 10 gün serisi için Bronz Başlangıç rozeti
    final bronzeDateKey = DateKey.addDays(todayKey, -2);
    final bronzeAchievement = Achievement(
      id: 'ach_bronze_kitap',
      userId: demoUserId,
      type: 'bronze',
      title: 'Bronz Başlangıç',
      threshold: 10,
      habitId: habit1Id,
      habitTitle: 'Kitap Oku',
      unlockedDateKey: bronzeDateKey,
      unlockedAtUtc: now
          .subtract(const Duration(days: 2))
          .toUtc()
          .toIso8601String(),
    );

    final updatedPrefs = Map<String, MotivationPreferences>.from(
      currentDoc.motivationPreferencesByUser,
    );
    updatedPrefs.putIfAbsent(
      demoUserId,
      () => MotivationPreferences.defaults(demoUserId),
    );

    return currentDoc.copyWith(
      demoSeedVersion: 1,
      activeUserId: currentDoc.activeUserId,
      users: [...currentDoc.users, demoUser],
      habits: [...currentDoc.habits, habit1, habit2, habit3, habit4],
      entries: [...currentDoc.entries, ...entries],
      achievements: [...currentDoc.achievements, bronzeAchievement],
      motivationPreferencesByUser: updatedPrefs,
    );
  }
}
