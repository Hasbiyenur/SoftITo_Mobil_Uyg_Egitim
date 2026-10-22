import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/time/date_key.dart';
import '../../data/models/achievement.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_entry.dart';
import '../../data/models/habit_schedule.dart';
import '../../data/repositories/habit_repository.dart';
import '../statistics/achievement_service.dart';
import 'services/schedule_service.dart';
import 'services/streak_service.dart';

class HabitController extends ChangeNotifier {
  final HabitRepository repository;
  final ScheduleService _scheduleService;
  final StreakService _streakService;
  final AchievementService _achievementService;

  List<Habit> _habits = [];
  List<HabitEntry> _entries = [];
  List<Achievement> _achievements = [];

  bool _isLoading = false;
  String? _errorMessage;
  String? _newAchievementAlert;

  HabitController({
    required this.repository,
    ScheduleService? scheduleService,
    StreakService? streakService,
    AchievementService? achievementService,
  }) : _scheduleService = scheduleService ?? ScheduleService(),
       _streakService = streakService ?? StreakService(),
       _achievementService = achievementService ?? AchievementService();

  List<Habit> get allHabits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => !h.isArchived).toList();
  List<HabitEntry> get entries => _entries;
  List<Achievement> get achievements => _achievements;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get newAchievementAlert => _newAchievementAlert;

  void consumeAchievementAlert() {
    _newAchievementAlert = null;
    notifyListeners();
  }

  Future<void> loadUserData(String userId, String todayKey) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _habits = await repository.getHabits(userId);
      _entries = await repository.getEntries(userId);
      _achievements = await repository.getAchievements(userId);

      // Başlangıç rozet kontrolü
      await _checkAndAwardAchievements(userId, todayKey);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bugün planlı olan tüm alışkanlıklar
  List<Habit> getTodayScheduledHabits(String todayKey) {
    final list = activeHabits.where((h) {
      final entry = getEntry(h.id, todayKey);
      return _scheduleService.isHabitScheduledOnDate(
        habit: h,
        dateKey: todayKey,
        isCompletedOnDate: entry?.isCompleted ?? false,
      );
    }).toList();

    // 6.2.8: Hedef saati artan sırada sıralanır. Eşitlikte oluşturulma sırası korunur.
    list.sort((a, b) {
      final timeA = a.activeScheduleForDate(todayKey).targetTime;
      final timeB = b.activeScheduleForDate(todayKey).targetTime;
      final cmp = timeA.compareTo(timeB);
      if (cmp != 0) return cmp;
      return a.createdAtUtc.compareTo(b.createdAtUtc);
    });

    return list;
  }

  /// Bugün Yapılacaklar (tamamlanmamışlar)
  List<Habit> getTodayTodoHabits(String todayKey) {
    return getTodayScheduledHabits(todayKey).where((h) {
      final entry = getEntry(h.id, todayKey);
      return entry == null || !entry.isCompleted;
    }).toList();
  }

  /// Bugün Yapılanlar (tamamlanmışlar, en son tamamlanan en üstte)
  List<Habit> getTodayDoneHabits(String todayKey) {
    final done = getTodayScheduledHabits(todayKey).where((h) {
      final entry = getEntry(h.id, todayKey);
      return entry != null && entry.isCompleted;
    }).toList();

    // 6.2.8: Yapılanlar bölümünde en son tamamlanan görev en üstte gösterilir
    done.sort((a, b) {
      final entryA = getEntry(a.id, todayKey);
      final entryB = getEntry(b.id, todayKey);
      final timeA = entryA?.completedAtUtc ?? '';
      final timeB = entryB?.completedAtUtc ?? '';
      return timeB.compareTo(timeA);
    });

    return done;
  }

  HabitEntry? getEntry(String habitId, String dateKey) {
    try {
      return _entries.firstWhere(
        (e) => e.habitId == habitId && e.dateKey == dateKey,
      );
    } catch (_) {
      return null;
    }
  }

  bool isCompletedOnDate(String habitId, String dateKey) {
    final entry = getEntry(habitId, dateKey);
    return entry?.isCompleted ?? false;
  }

  int getActiveStreak(Habit habit, String todayKey) {
    return _streakService.calculateActiveStreak(
      habit: habit,
      entries: _entries,
      todayKey: todayKey,
    );
  }

  BestStreakInfo getBestStreak(Habit habit, String todayKey) {
    return _streakService.calculateBestStreak(
      habit: habit,
      entries: _entries,
      todayKey: todayKey,
    );
  }

  /// Günlük özet kartı verileri
  ({int total, int completed, double ratio}) getDailySummary(String todayKey) {
    final scheduled = getTodayScheduledHabits(todayKey);
    final total = scheduled.length;
    final done = getTodayDoneHabits(todayKey).length;
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return (total: total, completed: done, ratio: ratio);
  }

  void Function({required Habit habit, required String todayKey})?
  onHabitCelebration;

  /// Tik atma / geri alma işlemi
  Future<void> toggleCheck({
    required String userId,
    required Habit habit,
    required String todayKey,
  }) async {
    final schedule = habit.activeScheduleForDate(todayKey);
    final existing = getEntry(habit.id, todayKey);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    HabitEntry updated;
    bool shouldCelebrate = false;

    if (existing == null) {
      // İlk kez tamamlanıyor
      updated = HabitEntry(
        id: 'entry_${habit.id}_$todayKey',
        userId: userId,
        habitId: habit.id,
        scheduleId: schedule.id,
        dateKey: todayKey,
        progressValue: 1,
        targetValue: 1,
        completedAtUtc: nowIso,
        celebrationShownAtUtc: nowIso,
        updatedAtUtc: nowIso,
      );
      shouldCelebrate = true;
    } else if (existing.isCompleted) {
      // Geri alma (0'a çek, completedAtUtc null yap, celebrationShownAtUtc'yi koru)
      updated = existing.copyWith(
        progressValue: 0,
        clearCompletedAt: true,
        updatedAtUtc: nowIso,
      );
    } else {
      // Tamamlama: Daha önce bugün kutlama gösterilmemişse ilk kez göster
      final isFirstCelebration = existing.celebrationShownAtUtc == null;
      updated = existing.copyWith(
        progressValue: 1,
        completedAtUtc: nowIso,
        celebrationShownAtUtc: isFirstCelebration
            ? nowIso
            : existing.celebrationShownAtUtc,
        updatedAtUtc: nowIso,
      );
      shouldCelebrate = isFirstCelebration;
    }

    await _saveEntryInternal(userId, updated, todayKey);
    if (shouldCelebrate) {
      onHabitCelebration?.call(habit: habit, todayKey: todayKey);
    }
  }

  /// Bar / Sayaç artırma
  Future<void> incrementCounter({
    required String userId,
    required Habit habit,
    required String todayKey,
  }) async {
    final schedule = habit.activeScheduleForDate(todayKey);
    final existing = getEntry(habit.id, todayKey);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final step = max(1, schedule.step);
    final currentVal = existing?.progressValue ?? 0;
    final newVal = min(schedule.targetValue, currentVal + step);

    final wasCompleted = existing?.isCompleted ?? false;
    final isNowCompleted = newVal >= schedule.targetValue;
    bool shouldCelebrate = false;

    HabitEntry updated;
    if (existing == null) {
      final isFirst = isNowCompleted;
      updated = HabitEntry(
        id: 'entry_${habit.id}_$todayKey',
        userId: userId,
        habitId: habit.id,
        scheduleId: schedule.id,
        dateKey: todayKey,
        progressValue: newVal,
        targetValue: schedule.targetValue,
        completedAtUtc: isNowCompleted ? nowIso : null,
        celebrationShownAtUtc: isFirst ? nowIso : null,
        updatedAtUtc: nowIso,
      );
      shouldCelebrate = isFirst;
    } else {
      final isFirst =
          !wasCompleted &&
          isNowCompleted &&
          existing.celebrationShownAtUtc == null;
      updated = existing.copyWith(
        progressValue: newVal,
        targetValue: schedule.targetValue,
        completedAtUtc: (!wasCompleted && isNowCompleted)
            ? nowIso
            : existing.completedAtUtc,
        celebrationShownAtUtc: isFirst
            ? nowIso
            : existing.celebrationShownAtUtc,
        updatedAtUtc: nowIso,
      );
      shouldCelebrate = isFirst;
    }

    await _saveEntryInternal(userId, updated, todayKey);
    if (shouldCelebrate) {
      onHabitCelebration?.call(habit: habit, todayKey: todayKey);
    }
  }

  /// Bar / Sayaç azaltma (Geri alma)
  Future<void> decrementCounter({
    required String userId,
    required Habit habit,
    required String todayKey,
  }) async {
    final schedule = habit.activeScheduleForDate(todayKey);
    final existing = getEntry(habit.id, todayKey);
    if (existing == null || existing.progressValue <= 0) return;

    final step = max(1, schedule.step);
    final newVal = max(0, existing.progressValue - step);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final isNowCompleted = newVal >= schedule.targetValue;
    final updated = existing.copyWith(
      progressValue: newVal,
      clearCompletedAt: !isNowCompleted,
      completedAtUtc: isNowCompleted ? existing.completedAtUtc : null,
      updatedAtUtc: nowIso,
    );

    await _saveEntryInternal(userId, updated, todayKey);
  }

  Future<void> _saveEntryInternal(
    String userId,
    HabitEntry entry,
    String todayKey,
  ) async {
    await repository.saveEntry(userId, entry);

    // Bellekteki listeyi güncelle
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      _entries[idx] = entry;
    } else {
      _entries.add(entry);
    }

    // Rozet değerlendirmesi & geri alma uzlaştırması (6.4.6)
    if (entry.isCompleted) {
      await _checkAndAwardAchievements(userId, todayKey);
    } else {
      await _reconcileInvalidatedAchievements(userId, todayKey);
    }

    notifyListeners();
  }

  Future<void> _checkAndAwardAchievements(
    String userId,
    String todayKey,
  ) async {
    final updatedAchievements = _achievementService.evaluateAchievements(
      userId: userId,
      habits: _habits,
      entries: _entries,
      todayKey: todayKey,
      existingAchievements: _achievements,
    );

    if (updatedAchievements.length > _achievements.length) {
      final newlyAdded = updatedAchievements
          .where((a) => !_achievements.any((old) => old.id == a.id))
          .toList();

      await repository.saveAchievements(userId, newlyAdded);
      _achievements = await repository.getAchievements(userId);

      if (newlyAdded.isNotEmpty) {
        _newAchievementAlert =
            'Tebrikler! "${newlyAdded.first.title}" rozeti kazandın! 🏆';
      }
    }
  }

  Future<void> _reconcileInvalidatedAchievements(
    String userId,
    String todayKey,
  ) async {
    final toRemove = _achievementService.findInvalidatedAchievements(
      userId: userId,
      habits: _habits,
      entries: _entries,
      todayKey: todayKey,
      currentAchievements: _achievements,
    );

    if (toRemove.isNotEmpty) {
      await repository.removeAchievements(userId, toRemove);
      _achievements = await repository.getAchievements(userId);
    }
  }

  /// Yeni alışkanlık ekleme veya düzenleme
  /// 6.4.7: Takip geçmişi varsa plan değişiklikleri yarından itibaren geçerli yeni sürüm olarak saklanır.
  Future<void> saveHabit({
    required String userId,
    required String? habitId,
    required String title,
    required String? description,
    required int intervalDays,
    required String startDateKey,
    required String counterType,
    required int targetValue,
    required String unit,
    required int step,
    required String targetTime,
    required bool reminderEnabled,
    required int iconCodePoint,
    required int colorValue,
    required String todayKey,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final tomorrowKey = DateKey.addDays(todayKey, 1);

    if (habitId == null) {
      // YENİ ALIŞKANLIK OLUŞTURMA
      final newHabitId = 'habit_${DateTime.now().millisecondsSinceEpoch}';
      final scheduleId = 'sched_${DateTime.now().millisecondsSinceEpoch}';

      final initialSchedule = HabitSchedule(
        id: scheduleId,
        habitId: newHabitId,
        intervalDays: intervalDays,
        anchorDateKey: startDateKey,
        counterType: counterType,
        targetValue: targetValue,
        unit: unit,
        step: step,
        targetTime: targetTime,
        reminderEnabled: reminderEnabled,
        effectiveFromDateKey: startDateKey,
      );

      final newHabit = Habit(
        id: newHabitId,
        userId: userId,
        title: title.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        createdAtUtc: nowIso,
        schedules: [initialSchedule],
      );

      await repository.saveHabit(userId, newHabit);
      _habits.add(newHabit);
      notifyListeners();
    } else {
      // MEVCUT ALIŞKANLIK DÜZENLEME
      final existingHabit = _habits.firstWhere((h) => h.id == habitId);
      final hasHistory = _entries.any((e) => e.habitId == habitId);

      List<HabitSchedule> updatedSchedules;

      if (!hasHistory) {
        // Geçmiş kayıt yok: İlk plan sürümünü doğrudan güncelle
        final updatedSchedule = existingHabit.latestSchedule.copyWith(
          intervalDays: intervalDays,
          anchorDateKey: startDateKey,
          counterType: counterType,
          targetValue: targetValue,
          unit: unit,
          step: step,
          targetTime: targetTime,
          reminderEnabled: reminderEnabled,
          effectiveFromDateKey: startDateKey,
        );
        updatedSchedules = [updatedSchedule];
      } else {
        // 6.4.7: Geçmişi olan görevde yeni plan yarından itibaren geçerli olur
        // Yarından sonra bir tarih seçilmişse effectiveFrom yine tomorrowKey olur, anchor ise seçilen tarih
        final effectiveFrom = tomorrowKey;
        final anchor = startDateKey.compareTo(tomorrowKey) > 0
            ? startDateKey
            : tomorrowKey;

        final newSchedule = HabitSchedule(
          id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
          habitId: habitId,
          intervalDays: intervalDays,
          anchorDateKey: anchor,
          counterType: counterType,
          targetValue: targetValue,
          unit: unit,
          step: step,
          targetTime: targetTime,
          reminderEnabled: reminderEnabled,
          effectiveFromDateKey: effectiveFrom,
        );

        // Eğer yarına ait bekleyen bir sürüm zaten varsa onu güncelle, yoksa yeni sürüm ekle
        final filteredSchedules = existingHabit.schedules
            .where((s) => s.effectiveFromDateKey != effectiveFrom)
            .toList();
        filteredSchedules.add(newSchedule);
        updatedSchedules = filteredSchedules;
      }

      final updatedHabit = existingHabit.copyWith(
        title: title.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        schedules: updatedSchedules,
      );

      await repository.saveHabit(userId, updatedHabit);
      final idx = _habits.indexWhere((h) => h.id == habitId);
      if (idx >= 0) {
        _habits[idx] = updatedHabit;
      }
      notifyListeners();
    }
  }

  /// Seçili görevleri mantıksal olarak kaldır (6.4.8: Geçmişi koru)
  Future<void> archiveHabits({
    required String userId,
    required List<String> habitIds,
    required String todayKey,
  }) async {
    await repository.archiveHabits(userId, habitIds, todayKey);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    _habits = _habits.map((h) {
      if (habitIds.contains(h.id)) {
        return h.copyWith(archivedAtUtc: nowIso, archivedOnDateKey: todayKey);
      }
      return h;
    }).toList();

    notifyListeners();
  }

  void clear() {
    _habits = [];
    _entries = [];
    _achievements = [];
    _newAchievementAlert = null;
    notifyListeners();
  }
}
