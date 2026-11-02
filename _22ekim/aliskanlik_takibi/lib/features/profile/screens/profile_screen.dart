import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/time/date_key.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/auth_controller.dart';
import '../../auth/screens/login_screen.dart';
import '../../habits/habit_controller.dart';
import '../../motivation/motivation_controller.dart';
import '../../notifications/notification_controller.dart';
import '../../pomodoro/pomodoro_controller.dart';
import '../../statistics/screens/statistics_screen.dart';
import '../settings_controller.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final habitCtrl = context.watch<HabitController>();
    final notifCtrl = context.read<NotificationController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final user = auth.currentUser;
    final todayKey = DateKey.today().value;
    final activeHabits = habitCtrl.activeHabits;
    final totalCompleted = habitCtrl.entries.where((e) => e.isCompleted).length;

    // En yüksek streak rekoru
    var bestStreak = 0;
    var bestTitle = '';
    String? bestDate;

    for (final h in habitCtrl.allHabits) {
      final b = habitCtrl.getBestStreak(h, todayKey);
      if (b.streak > bestStreak) {
        bestStreak = b.streak;
        bestTitle = h.title;
        bestDate = b.achievedDateKey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Seçili Avatar ve Kullanıcı Bilgileri (Avatar seçimi Ayarlar'dadır)
              Center(
                child: Column(
                  children: [
                    AppAvatar(
                      avatarId: user?.avatarId ?? 'fox',
                      size: 84,
                      showBorder: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Kullanıcı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Alışkanlık Serilerim
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alışkanlık Serilerim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (bestStreak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkWarning : AppColors.warning)
                                .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🏆 Rekor: $bestStreak gün',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkWarning
                              : AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (activeHabits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'İlk serini oluşturmak için bir görev tamamla.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...activeHabits.map((habit) {
                  final streak = habitCtrl.getActiveStreak(habit, todayKey);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppIcons.fromCodePoint(habit.iconCodePoint),
                              size: 20,
                              color: Color(habit.colorValue),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 $streak gün',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),

              // 3. Özet İstatistik Sayaçları
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      label: 'Aktif Görev',
                      value: '${activeHabits.length}',
                      icon: Icons.checklist_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      label: 'Tamamlama',
                      value: '$totalCompleted',
                      icon: Icons.done_all_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      label: 'En Uzun Seri',
                      value: '$bestStreak',
                      icon: Icons.local_fire_department_rounded,
                      color: isDark ? AppColors.darkWarning : AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // En yüksek rekor kartı
              if (bestStreak > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppColors.darkWarning
                                      : AppColors.warning)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: isDark
                              ? AppColors.darkWarning
                              : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'En yüksek seri: $bestStreak gün — $bestTitle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (bestDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Elde edildiği tarih: ${DateFormat("d MMMM y", "tr_TR").format(DateKey(bestDate).toLocalMidnight())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // 4. İstatistikler ve Rozetler Giriş Kartı
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primaryContainer,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        radius: 20,
                        child: Icon(
                          Icons.insights_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İstatistikler ve Rozetler',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Başarı oranları, grafikler ve rozet vitrini',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Çıkış Yap butonu
              PrimaryButton(
                text: 'Çıkış Yap',
                isOutlined: true,
                icon: Icons.logout_rounded,
                backgroundColor: isDark ? AppColors.darkError : AppColors.error,
                foregroundColor: isDark ? AppColors.darkError : AppColors.error,
                onPressed: () async {
                  final motivationCtrl = context.read<MotivationController>();
                  final pomodoroCtrl = context.read<PomodoroController>();
                  final settingsCtrl = context.read<SettingsController>();

                  // Çalışan Pomodoro varsa duraklat ve kalan süreyi kaydet
                  if (pomodoroCtrl.state.isRunning) {
                    await pomodoroCtrl.pause();
                  }

                  await auth.logout();
                  habitCtrl.clear();
                  notifCtrl.clear();
                  motivationCtrl.clear();
                  settingsCtrl.resetToLight();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
