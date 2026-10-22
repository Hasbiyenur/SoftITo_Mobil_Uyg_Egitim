import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/app_clock.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/auth_controller.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../habits/habit_controller.dart';
import '../../habits/widgets/habit_card.dart';
import '../../notifications/notification_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNotificationSheet(BuildContext context, String userId) {
    final notifCtrl = context.read<NotificationController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentReminders = context
                .watch<NotificationController>()
                .reminders;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Uygulama İçi Hatırlatmalar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (currentReminders.any((r) => !r.isRead))
                          TextButton(
                            onPressed: () {
                              notifCtrl.markAllAsRead(userId);
                            },
                            child: const Text('Tümünü Oku'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (currentReminders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Henüz aktif bir hatırlatma yok.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: currentReminders.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final rem = currentReminders[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: rem.isRead
                                    ? AppColors.surfaceVariant
                                    : AppColors.primaryContainer,
                                child: Icon(
                                  Icons.alarm_rounded,
                                  size: 18,
                                  color: rem.isRead
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.primary,
                                ),
                              ),
                              title: Text(
                                rem.habitTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: rem.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${rem.message} • ${rem.reminderTime}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: !rem.isRead
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.done_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        notifCtrl.markAsRead(userId, rem.id);
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final habitCtrl = context.watch<HabitController>();
    final notifCtrl = context.watch<NotificationController>();

    final user = auth.currentUser;
    final clock = AppClock();
    final todayKey = clock.todayKey();
    final now = clock.now();

    final greeting = clock.greeting();
    final firstName = user?.firstName ?? 'Kullanıcı';
    final dateFormatted = DateFormat('d MMMM y, EEEE', 'tr_TR').format(now);

    final summary = habitCtrl.getDailySummary(todayKey);
    final todoHabits = habitCtrl.getTodayTodoHabits(todayKey);
    final doneHabits = habitCtrl.getTodayDoneHabits(todayKey);

    // Yeni rozet kazanıldıysa kısa bir snackbar göster
    if (habitCtrl.newAchievementAlert != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(habitCtrl.newAchievementAlert!),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        habitCtrl.consumeAchievementAlert();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await habitCtrl.loadUserData(user.id, todayKey);
              await notifCtrl.checkAndGenerate(
                userId: user.id,
                habits: habitCtrl.activeHabits,
                todayKey: todayKey,
                now: now,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ÜST BÖLÜM: Logo, Selamlama, Tarih, Takvim & Bildirim Simgeleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 44, showText: false),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting, $firstName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormatted,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          tooltip: 'Takvim',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CalendarScreen(),
                              ),
                            );
                          },
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                              ),
                              tooltip: 'Hatırlatmalar',
                              onPressed: () {
                                if (user != null) {
                                  _showNotificationSheet(context, user.id);
                                }
                              },
                            ),
                            if (notifCtrl.unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${notifCtrl.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. GÜNLÜK ÖZET KARTI
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            summary.total == 0
                                ? 'Bugün planlanmış bir görev yok'
                                : 'Bugün ${summary.total} görevden ${summary.completed}\'sini tamamladın.',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackground,
                            ),
                          ),
                          Text(
                            '%${(summary.ratio * 100).round()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: summary.ratio,
                          minHeight: 10,
                          backgroundColor: AppColors.outlineVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. BUGÜN YAPILACAKLAR
                Row(
                  children: [
                    const Icon(
                      Icons.playlist_play_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bugün Yapılacaklar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${todoHabits.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (todoHabits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Center(
                      child: Text(
                        summary.total > 0
                            ? 'Harika! Bugünün tüm görevlerini tamamladın 🎉'
                            : 'Bugüne planlanmış bir görev bulunmuyor.',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ...todoHabits.map((habit) {
                    final streak = habitCtrl.getActiveStreak(habit, todayKey);
                    final entry = habitCtrl.getEntry(habit.id, todayKey);
                    return HabitCard(
                      habit: habit,
                      entry: entry,
                      streak: streak,
                      dateKey: todayKey,
                      onToggleCheck: () {
                        if (user != null) {
                          habitCtrl.toggleCheck(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                      onIncrement: () {
                        if (user != null) {
                          habitCtrl.incrementCounter(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                      onDecrement: () {
                        if (user != null) {
                          habitCtrl.decrementCounter(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                    );
                  }),

                const SizedBox(height: 16),

                // 4. YAPILANLAR BÖLÜMÜ
                if (doneHabits.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yapılanlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${doneHabits.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...doneHabits.map((habit) {
                    final streak = habitCtrl.getActiveStreak(habit, todayKey);
                    final entry = habitCtrl.getEntry(habit.id, todayKey);
                    return HabitCard(
                      habit: habit,
                      entry: entry,
                      streak: streak,
                      dateKey: todayKey,
                      onToggleCheck: () {
                        if (user != null) {
                          habitCtrl.toggleCheck(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                      onIncrement: () {
                        if (user != null) {
                          habitCtrl.incrementCounter(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                      onDecrement: () {
                        if (user != null) {
                          habitCtrl.decrementCounter(
                            userId: user.id,
                            habit: habit,
                            todayKey: todayKey,
                          );
                        }
                      },
                    );
                  }),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
