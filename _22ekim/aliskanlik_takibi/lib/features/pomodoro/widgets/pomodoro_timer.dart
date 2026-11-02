import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/pomodoro_state.dart';

class PomodoroTimer extends StatelessWidget {
  final PomodoroState state;

  const PomodoroTimer({super.key, required this.state});

  String _formatTime(int totalSeconds) {
    final s = totalSeconds.clamp(0, 99999);
    final minutes = s ~/ 60;
    final seconds = s % 60;
    return '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final progress = state.plannedSeconds > 0
        ? (state.remainingSeconds / state.plannedSeconds).clamp(0.0, 1.0)
        : 0.0;

    String phaseTitle;
    Color phaseColor;
    IconData phaseIcon;

    if (state.isFocus) {
      phaseTitle = 'Odaklanma';
      phaseColor = colorScheme.primary;
      phaseIcon = Icons.center_focus_strong_rounded;
    } else if (state.isShortBreak) {
      phaseTitle = 'Kısa Mola';
      phaseColor = const Color(0xFF4A7298);
      phaseIcon = Icons.coffee_rounded;
    } else {
      phaseTitle = 'Uzun Mola';
      phaseColor = const Color(0xFF7C6DAF);
      phaseIcon = Icons.nature_people_rounded;
    }

    return Column(
      children: [
        // Aşamayı ve Döngüyü Belirten Üst Etiket
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: phaseColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(phaseIcon, size: 16, color: phaseColor),
                  const SizedBox(width: 6),
                  Text(
                    phaseTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: phaseColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Döngü: ${state.cycleCompletedCount}/4',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Dairesel Sayaç
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan dairesi
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              // İlerleme dairesi
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                ),
              ),
              // İçerik (Süre & Hedef Başlığı)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(state.remainingSeconds),
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      state.titleSnapshot ?? 'Odaklanma',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.status == 'running'
                        ? 'Çalışıyor'
                        : (state.status == 'paused' ? 'Duraklatıldı' : 'Hazır'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state.status == 'running'
                          ? phaseColor
                          : (state.status == 'paused'
                                ? (isDark
                                      ? AppColors.darkWarning
                                      : AppColors.warning)
                                : colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
