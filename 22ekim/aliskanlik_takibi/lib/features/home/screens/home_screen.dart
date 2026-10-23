import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/app_clock.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/sweet_animated_logo.dart';
import '../../auth/auth_controller.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../habits/habit_controller.dart';
import '../../habits/widgets/habit_card.dart';
import '../../notifications/notification_controller.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNotificationSheet(BuildContext context, String userId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<NotificationController>(
          builder: (ctx, notifCtrl, _) {
            final currentReminders = notifCtrl.activeReminders;

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
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Uygulama İçi Hatırlatmalar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (currentReminders.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              notifCtrl.markAllAsRead(userId);
                            },
                            child: const Text('Tümünü Oku'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (currentReminders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Henüz aktif bir hatırlatma yok.',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                            return Dismissible(
                              key: ValueKey(rem.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Okundu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.done_all_rounded,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (_) {
                                notifCtrl.markAsRead(userId, rem.id);
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.alarm_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  rem.habitTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  '${rem.message} • ${rem.reminderTime}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.done_rounded,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  tooltip: 'Okundu olarak işaretle ve kaldır',
                                  onPressed: () {
                                    notifCtrl.markAsRead(userId, rem.id);
                                  },
                                ),
                              ),
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Yeni rozet kazanıldıysa kısa bir snackbar göster
    if (habitCtrl.newAchievementAlert != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(habitCtrl.newAchievementAlert!),
            backgroundColor: colorScheme.primary,
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
                // 1. ÜST BÖLÜM: Logo, Selamlama, Tarih, Takvim - Bildirim - Profil Avatarı Sıralaması
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SweetAnimatedLogo(
                            size: 44,
                            tooltip: 'Alışkanlık Takibi',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$greeting, $firstName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormatted,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                                child: IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkWarning
                                          : AppColors.warning,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${notifCtrl.unreadCount}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.black87
                                              : Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        // Profil Avatarı (Tıklanınca Profil'i açar)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Tooltip(
                            message: 'Profil',
                            child: AppAvatar(
                              avatarId: user?.avatarId ?? 'fox',
                              size: 38,
                              showBorder: true,
                            ),
                          ),
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
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.03,
                        ),
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
                          Expanded(
                            child: Text(
                              summary.total == 0
                                  ? 'Bugün planlanmış bir görev yok'
                                  : 'Bugün ${summary.total} görevden ${summary.completed}\'sini tamamladın.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '%${(summary.ratio * 100).round()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
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
                          backgroundColor: colorScheme.outlineVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
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
                    Icon(
                      Icons.playlist_play_rounded,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Bugün Yapılacaklar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${todoHabits.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Center(
                      child: Text(
                        summary.total > 0
                            ? 'Harika! Bugünün tüm görevlerini tamamladın 🎉'
                            : 'Bugüne planlanmış bir görev bulunmuyor.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
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
                      Flexible(
                        child: Text(
                          'Yapılanlar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${doneHabits.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
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
