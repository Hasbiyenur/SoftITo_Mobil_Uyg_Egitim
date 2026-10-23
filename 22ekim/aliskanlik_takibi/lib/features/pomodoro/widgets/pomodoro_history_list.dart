import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/date_key.dart';
import '../../../data/models/pomodoro_session.dart';

class PomodoroHistoryList extends StatelessWidget {
  final List<PomodoroSession> sessions;

  const PomodoroHistoryList({super.key, required this.sessions});

  String _formatDateHeader(String dateKey) {
    final today = DateKey.today().value;
    final yesterday = DateKey.format(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (dateKey == today) {
      return 'Bugün';
    } else if (dateKey == yesterday) {
      return 'Dün';
    } else {
      final date = DateKey(dateKey).toLocalMidnight();
      return DateFormat('d MMMM y, EEEE', 'tr_TR').format(date);
    }
  }

  String _formatTime(String isoUtc) {
    try {
      final dt = DateTime.parse(isoUtc).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'İlk Pomodoro oturumunu başlatarak odaklanmaya başlayabilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Günlere göre grupla (en yeni gün üstte)
    final Map<String, List<PomodoroSession>> grouped = {};
    for (final s in sessions) {
      grouped.putIfAbsent(s.endedOnDateKey, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: grouped.entries.map((entry) {
        final dateKey = entry.key;
        final list = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(dateKey),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            ...list.map((session) {
              final isCompleted = session.isCompleted;
              final plannedMinutes = session.plannedSeconds ~/ 60;
              final focusedMinutes = session.focusedSeconds ~/ 60;
              final focusedSecondsRemainder = session.focusedSeconds % 60;

              final focusedText = focusedMinutes > 0
                  ? '$focusedMinutes dk ${focusedSecondsRemainder > 0 ? "$focusedSecondsRemainder sn " : ""}odaklanıldı'
                  : '${session.focusedSeconds} sn odaklanıldı';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : (isDark
                                      ? AppColors.darkWarning
                                      : AppColors.warning)
                                  .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_rounded,
                        size: 20,
                        color: isCompleted
                            ? AppColors.success
                            : (isDark
                                  ? AppColors.darkWarning
                                  : AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.titleSnapshot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatTime(session.startedAtUtc)} - ${_formatTime(session.endedAtUtc)} • $focusedText (Plan: $plannedMinutes dk)',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : (isDark
                                      ? AppColors.darkWarning
                                      : AppColors.warning)
                                  .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCompleted ? 'Tamamlandı' : 'Yarıda bırakıldı',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.success
                              : (isDark
                                    ? AppColors.darkWarning
                                    : AppColors.warning),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
