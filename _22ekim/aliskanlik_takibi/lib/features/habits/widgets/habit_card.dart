import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import 'progress_counter.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitEntry? entry;
  final int streak;
  final String dateKey;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isEditMode;
  final VoidCallback? onToggleCheck;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.entry,
    required this.streak,
    required this.dateKey,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.isEditMode = false,
    this.onToggleCheck,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final schedule = habit.activeScheduleForDate(dateKey);
    final isCompleted = entry?.isCompleted ?? false;
    final habitColor = Color(habit.colorValue);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final completedSurface = isDark
        ? AppColors.darkCompletedSurface
        : AppColors.completedSurface;
    final completedBorder = isDark
        ? AppColors.darkCompletedBorder
        : AppColors.completedBorder;
    final completedText = isDark
        ? AppColors.darkCompletedText
        : AppColors.completedText;

    // Tekrar metni
    final intervalText = schedule.intervalDays == 1
        ? 'Her gün'
        : '${schedule.intervalDays} günde bir';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? completedSurface
            : (isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : (isCompleted ? completedBorder : colorScheme.outline),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Kaldırma seçim kutusu
                    if (isSelectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        activeColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (_) => onTap?.call(),
                      ),
                      const SizedBox(width: 4),
                    ],

                    // Simge kutusu
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: habitColor.withValues(
                          alpha: isCompleted ? 0.12 : 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.fromCodePoint(habit.iconCodePoint),
                        color: isCompleted ? completedText : habitColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Başlık ve Bilgiler
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: completedText,
                              decorationThickness: 1.8,
                              color: isCompleted
                                  ? completedText
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '$intervalText • ${schedule.targetTime}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCompleted
                                        ? completedText
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (streak > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? (isDark
                                              ? AppColors.darkOutlineVariant
                                              : AppColors.outlineVariant)
                                        : colorScheme.primaryContainer
                                              .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🔥 $streak',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isCompleted
                                              ? completedText
                                              : (isDark
                                                    ? AppColors.darkPrimary
                                                    : AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Düzenleme modu oku veya Tik Butonu
                    if (isEditMode) ...[
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ] else if (!isSelectionMode && schedule.isCheckType) ...[
                      _buildCheckButton(
                        isCompleted: isCompleted,
                        habitColor: habitColor,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ],
                ),

                // Bar / Sayaç Tipi Kontrol
                if (!isSelectionMode &&
                    !isEditMode &&
                    schedule.isCounterType) ...[
                  const SizedBox(height: 14),
                  ProgressCounter(
                    currentValue: entry?.progressValue ?? 0,
                    targetValue: schedule.targetValue,
                    unit: schedule.unit,
                    step: schedule.step,
                    isCompleted: isCompleted,
                    accentColor: habitColor,
                    onIncrement: onIncrement ?? () {},
                    onDecrement: onDecrement ?? () {},
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckButton({
    required bool isCompleted,
    required Color habitColor,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleCheck,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.success : colorScheme.outline,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
