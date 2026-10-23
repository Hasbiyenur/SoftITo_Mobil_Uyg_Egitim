import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/date_key.dart';
import '../../habits/habit_controller.dart';
import '../statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isWeekly = true; // true = Bu Hafta, false = Bu Ay
  final _statsService = StatisticsService();

  @override
  Widget build(BuildContext context) {
    final habitCtrl = context.watch<HabitController>();
    final todayKey = DateKey.today().value;

    final habits = habitCtrl.allHabits;
    final entries = habitCtrl.entries;
    final achievements = habitCtrl.achievements;

    final periodStats = _statsService.calculatePeriodStats(
      habits: habits,
      entries: entries,
      todayKey: todayKey,
      isWeekly: _isWeekly,
    );

    final dayStats = _statsService.get7DayStats(
      habits: habits,
      entries: entries,
      todayKey: todayKey,
    );

    final bestRecord = _statsService.getOverallBestRecord(
      habits: habits,
      entries: entries,
      todayKey: todayKey,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler ve Rozetler')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hafta / Ay seçimi
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Bu Hafta'),
                    icon: Icon(Icons.date_range_rounded, size: 18),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Bu Ay'),
                    icon: Icon(Icons.calendar_month_rounded, size: 18),
                  ),
                ],
                selected: {_isWeekly},
                onSelectionChanged: (val) {
                  setState(() {
                    _isWeekly = val.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Dönem başarı oranı kartı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Text(
                      _isWeekly
                          ? 'Haftalık Başarı Oranı'
                          : 'Aylık Başarı Oranı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '%${periodStats.completionPercentage}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      periodStats.periodDescription.isNotEmpty
                          ? periodStats.periodDescription
                          : '${periodStats.totalScheduled} planlı tekrardan ${periodStats.totalCompleted} tanesi tamamlandı.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7 Günlük Başarı Grafiği
              Text(
                'Haftalık Başarı Grafiği (Son 7 Gün)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dayStats.map((d) {
                    final isToday = d.dateKey == todayKey;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d.scheduledCount > 0
                              ? '${(d.ratio * 100).round()}%'
                              : '-',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: d.scheduledCount > 0
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 24,
                          height: 70,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: d.ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: d.ratio >= 1.0
                                    ? AppColors.success
                                    : colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Tüm Zamanların Rekoru
              Text(
                'Tüm Zamanların Rekoru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkWarning : AppColors.warning)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: isDark
                            ? AppColors.darkWarning
                            : AppColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bestRecord.streak > 0
                                ? '${bestRecord.streak} gün kesintisiz seri'
                                : 'Henüz seri rekoru yok',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bestRecord.streak > 0
                                ? '${bestRecord.habitTitle}${bestRecord.achievedDateKey != null ? " • ${DateFormat("d MMMM y", "tr_TR").format(DateKey(bestRecord.achievedDateKey!).toLocalMidnight())}" : ""}'
                                : 'Planlı günlerde görevlerini tamamlayarak rekor kırabilirsin.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Başarı Rozetleri Vitrini
              Text(
                'Başarı Rozetleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rozetler tek bir alışkanlığın kesintisiz planlı gün serisiyle kazanılır.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              _buildBadgeCard(
                type: 'bronze',
                title: 'Bronz Başlangıç',
                subtitle: 'Tek bir alışkanlıkta en az 10 planlı gün serisi',
                threshold: 10,
                iconColor: const Color(0xFFCD7F32),
                achievements: achievements,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 10),

              _buildBadgeCard(
                type: 'silver',
                title: 'Gümüş Devamlılık',
                subtitle: 'Tek bir alışkanlıkta en az 25 planlı gün serisi',
                threshold: 25,
                iconColor: const Color(0xFFA8A8A8),
                achievements: achievements,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 10),

              _buildBadgeCard(
                type: 'gold',
                title: 'Altın İstikrar',
                subtitle: 'Tek bir alışkanlıkta en az 50 planlı gün serisi',
                threshold: 50,
                iconColor: const Color(0xFFFFD700),
                achievements: achievements,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard({
    required String type,
    required String title,
    required String subtitle,
    required int threshold,
    required Color iconColor,
    required List achievements,
    required ColorScheme colorScheme,
  }) {
    final unlocked = achievements.where((a) => a.type == type).toList();
    final isUnlocked = unlocked.isNotEmpty;
    final firstUnlocked = isUnlocked ? unlocked.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? colorScheme.outline : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? iconColor.withValues(alpha: 0.18)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_outline_rounded,
              color: isUnlocked
                  ? iconColor
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Kazanıldı',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(
                      alpha: isUnlocked ? 1.0 : 0.7,
                    ),
                  ),
                ),
                if (firstUnlocked != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Kazandıran: ${firstUnlocked.habitTitle} • ${DateFormat("d MMMM y", "tr_TR").format(DateKey(firstUnlocked.unlockedDateKey).toLocalMidnight())}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
