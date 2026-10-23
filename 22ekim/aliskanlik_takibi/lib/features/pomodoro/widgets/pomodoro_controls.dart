import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../pomodoro_controller.dart';

class PomodoroControls extends StatelessWidget {
  final VoidCallback? onSelectTask;

  const PomodoroControls({super.key, this.onSelectTask});

  void _showAbandonDialog(
    BuildContext context,
    PomodoroController pomodoroCtrl,
  ) {
    final state = pomodoroCtrl.state;
    final isFocus = state.isFocus;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isFocus ? 'Oturumu Bitir' : 'Molayı Bitir'),
          content: Text(
            isFocus
                ? 'Mevcut odaklanma oturumunu sonlandırmak istediğinize emin misiniz? Yapılan çalışma "Yarıda bırakıldı" olarak geçmişe kaydedilecek.'
                : 'Molayı erken sonlandırıp bir sonraki çalışma için hazır duruma geçmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkError : AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                pomodoroCtrl.abandonSession();
              },
              child: const Text('Sonlandır'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroCtrl = context.watch<PomodoroController>();
    final state = pomodoroCtrl.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    String startLabel;
    if (state.isFocus) {
      startLabel = 'Başlat';
    } else if (state.isShortBreak) {
      startLabel = 'Molayı Başlat';
    } else {
      startLabel = 'Uzun Molayı Başlat';
    }

    if (state.isReady) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                pomodoroCtrl.start();
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(
                startLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Duraklat veya Devam Et
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: () {
              if (state.isRunning) {
                pomodoroCtrl.pause();
              } else {
                pomodoroCtrl.resume();
              }
            },
            icon: Icon(
              state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 24,
            ),
            label: Text(
              state.isRunning ? 'Duraklat' : 'Devam Et',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Oturumu Bitir (Onay İster)
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: () => _showAbandonDialog(context, pomodoroCtrl),
            icon: Icon(
              Icons.stop_rounded,
              size: 20,
              color: isDark ? AppColors.darkError : AppColors.error,
            ),
            label: Text(
              'Bitir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkError : AppColors.error,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? AppColors.darkError : AppColors.error,
              ),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
