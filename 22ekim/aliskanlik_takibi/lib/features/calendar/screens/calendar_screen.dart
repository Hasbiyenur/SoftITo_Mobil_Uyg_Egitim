import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/time/date_key.dart';
import '../../../data/models/habit.dart';
import '../../habits/habit_controller.dart';
import '../../habits/services/schedule_service.dart';
import '../widgets/calendar_legend.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayedMonth;
  late String _selectedDateKey;
  String? _selectedHabitId; // null = Tüm Alışkanlıklar
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDateKey = DateKey.today().value;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitCtrl = context.watch<HabitController>();
    final allHabits = habitCtrl.allHabits;
    final activeHabits = habitCtrl.activeHabits;
    final entries = habitCtrl.entries;
    final todayKey = DateKey.today().value;

    final monthTitle = DateFormat('MMMM y', 'tr_TR').format(_displayedMonth);
    const weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    // Ay ızgarası hesaplamaları
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final firstWeekday = _displayedMonth.weekday; // 1 = Pzt, 7 = Paz
    final leadingBlanks = firstWeekday - 1;

    // Seçili tarihin görevlerini bul
    final habitsOnSelectedDate = allHabits.where((h) {
      final isComp = entries.any(
        (e) =>
            e.habitId == h.id && e.dateKey == _selectedDateKey && e.isCompleted,
      );
      return _scheduleService.isHabitScheduledOnDate(
        habit: h,
        dateKey: _selectedDateKey,
        isCompletedOnDate: isComp,
      );
    }).toList();

    // Gösterge (Legend) için alışkanlık listesi
    final legendHabits = _selectedHabitId != null
        ? allHabits.where((h) => h.id == _selectedHabitId).toList()
        : activeHabits;

    return Scaffold(
      appBar: AppBar(title: const Text('Takvim')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Alışkanlık Filtresi Seçici
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedHabitId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'Tüm Alışkanlıklar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...activeHabits.map((h) {
                        return DropdownMenuItem<String?>(
                          value: h.id,
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.fromCodePoint(h.iconCodePoint),
                                size: 18,
                                color: Color(h.colorValue),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                h.title,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedHabitId = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ay Navigasyonu (< Ekim 2026 >)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    monthTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.onBackground,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hafta Günleri Başlıkları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((d) {
                  return SizedBox(
                    width: 38,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Ay Günleri Izgarası
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: leadingBlanks + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < leadingBlanks) {
                    return const SizedBox.shrink();
                  }

                  final day = index - leadingBlanks + 1;
                  final dayDate = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    day,
                  );
                  final cellDateKey = DateKey.fromDate(dayDate).value;

                  final isToday = cellDateKey == todayKey;
                  final isSelected = cellDateKey == _selectedDateKey;
                  final isFuture = cellDateKey.compareTo(todayKey) > 0;

                  // Bu günde tamamlanmış görevleri kendi renkleriyle bul
                  List<Habit> completedHabits = [];
                  if (!isFuture) {
                    if (_selectedHabitId == null) {
                      completedHabits = allHabits.where((h) {
                        final entry = habitCtrl.getEntry(h.id, cellDateKey);
                        return entry != null && entry.isCompleted;
                      }).toList();
                    } else {
                      final entry = habitCtrl.getEntry(
                        _selectedHabitId!,
                        cellDateKey,
                      );
                      if (entry != null && entry.isCompleted) {
                        final h = allHabits
                            .where((x) => x.id == _selectedHabitId)
                            .firstOrNull;
                        if (h != null) completedHabits = [h];
                      }
                    }
                  }

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDateKey = cellDateKey;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surfaceVariant
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isToday
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : Colors.transparent),
                          width: isSelected ? 2 : (isToday ? 1.5 : 0),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 6,
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: (isToday || isSelected)
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isFuture
                                    ? AppColors.onSurfaceVariant.withValues(
                                        alpha: 0.4,
                                      )
                                    : (completedHabits.isNotEmpty
                                          ? AppColors.onBackground
                                          : AppColors.onSurface),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            child: _buildMarkers(completedHabits),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Renk Açıklama Listesi (Legend)
              CalendarLegend(habits: legendHabits),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Seçili Tarihin Görev Detayları
              Text(
                DateFormat(
                  'd MMMM y, EEEE',
                  'tr_TR',
                ).format(DateKey(_selectedDateKey).toLocalMidnight()),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              if (habitsOnSelectedDate.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Center(
                    child: Text(
                      'Bu tarihte planlanmış bir görev bulunmuyor.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...habitsOnSelectedDate.map((habit) {
                  final entry = habitCtrl.getEntry(habit.id, _selectedDateKey);
                  final isDone = entry?.isCompleted ?? false;
                  final sched = habit.activeScheduleForDate(_selectedDateKey);
                  final habitColor = Color(habit.colorValue);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.completedSurface
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? AppColors.completedBorder
                            : AppColors.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Görevin kendine has soft rengiyle gösterge çizgisi
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: habitColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          AppIcons.fromCodePoint(habit.iconCodePoint),
                          size: 18,
                          color: habitColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDone
                                  ? AppColors.completedText
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (sched.isCounterType && entry != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '${entry.progressValue}/${sched.targetValue} ${sched.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDone
                                    ? AppColors.completedText
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isDone
                              ? AppColors.success
                              : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Hücre altındaki renkli görev noktalarını çizer (en fazla 3, fazlası için +n)
  Widget _buildMarkers(List<Habit> completedHabits) {
    if (completedHabits.isEmpty) return const SizedBox.shrink();

    if (completedHabits.length <= 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: completedHabits.map((h) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Color(h.colorValue),
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      );
    }

    // 3'ten fazla görev tamamlandıysa: İlk 2 görevin rengi + "+n"
    final remaining = completedHabits.length - 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...completedHabits.take(2).map((h) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Color(h.colorValue),
              shape: BoxShape.circle,
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Text(
            '+$remaining',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
