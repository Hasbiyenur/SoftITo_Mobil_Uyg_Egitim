import 'package:flutter/foundation.dart';

import '../../../data/models/habit.dart';
import '../../../data/models/habit_reminder.dart';
import '../../../data/repositories/habit_repository.dart';
import 'reminder_service.dart';

class NotificationController extends ChangeNotifier {
  final HabitRepository repository;
  final ReminderService _reminderService;

  List<HabitReminder> _reminders = [];
  bool _isLoading = false;

  NotificationController({
    required this.repository,
    ReminderService? reminderService,
  }) : _reminderService = reminderService ?? ReminderService();

  List<HabitReminder> get reminders => _reminders;
  int get unreadCount => _reminders.where((r) => !r.isRead).length;
  bool get isLoading => _isLoading;

  Future<void> loadReminders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reminders = await repository.getReminders(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndGenerate({
    required String userId,
    required List<Habit> habits,
    required String todayKey,
    required DateTime now,
  }) async {
    final newReminders = _reminderService.generateInAppReminders(
      userId: userId,
      habits: habits,
      todayKey: todayKey,
      now: now,
      existingReminders: _reminders,
    );

    if (newReminders.isNotEmpty) {
      await repository.saveReminders(userId, newReminders);
      _reminders = await repository.getReminders(userId);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String userId, String reminderId) async {
    await repository.markReminderAsRead(userId, reminderId);
    _reminders = _reminders.map((r) {
      if (r.id == reminderId) return r.copyWith(isRead: true);
      return r;
    }).toList();
    notifyListeners();
  }

  Future<void> markAllAsRead(String userId) async {
    for (final r in _reminders) {
      if (!r.isRead) {
        await repository.markReminderAsRead(userId, r.id);
      }
    }
    _reminders = _reminders.map((r) => r.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clear() {
    _reminders = [];
    notifyListeners();
  }
}
