import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../habits/habit_controller.dart';
import '../pomodoro_controller.dart';
import '../widgets/pomodoro_controls.dart';
import '../widgets/pomodoro_duration_form.dart';
import '../widgets/pomodoro_history_list.dart';
import '../widgets/pomodoro_timer.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  String? _selectedHabitId;
  String? _customTaskTitle;

  void _showTaskSelectDialog(BuildContext context) {
    final habitCtrl = context.read<HabitController>();
    final activeHabits = habitCtrl.activeHabits;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textController = TextEditingController(text: _customTaskTitle ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Çalışma Hedefi Belirle'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bir alışkanlık seçebilir veya özel bir çalışma başlığı yazabilirsin:',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText:
                            'Örn: Kitap Okuma, Kodlama (Varsayılan: Odaklanma)',
                        labelText: 'Özel Başlık',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          _customTaskTitle = val.trim();
                          if (val.trim().isNotEmpty) {
                            _selectedHabitId = null;
                          }
                        });
                      },
                    ),
                    if (activeHabits.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Veya Aktif Görevlerinden Seç:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeHabits.length,
                          itemBuilder: (context, i) {
                            final h = activeHabits[i];
                            final isSel = _selectedHabitId == h.id;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(h.colorValue)
                                    .withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Color(h.colorValue),
                                ),
                              ),
                              title: Text(
                                h.title,
                                style: TextStyle(
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSel
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              trailing: isSel
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: colorScheme.primary,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () {
                                setDialogState(() {
                                  _selectedHabitId = h.id;
                                  _customTaskTitle = h.title;
                                  textController.text = h.title;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedHabitId = null;
                      _customTaskTitle = null;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Temizle'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (textController.text.trim().isNotEmpty) {
                        _customTaskTitle = textController.text.trim();
                      }
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Uygula'),
                ),
              ],
            );
          },
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

    final targetTitle = _customTaskTitle?.isNotEmpty == true
        ? _customTaskTitle!
        : (state.titleSnapshot ?? 'Odaklanma');

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Üst Açıklama
              Text(
                'Odaklanma ve mola döngüsü ile verimli çalış.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Süre Ayarları Bölümü (Sayacın üzerinde)
              const PomodoroDurationForm(),
              const SizedBox(height: 20),

              // 3. Çalışma Hedefi Seçimi (İsteğe Bağlı)
              if (state.isFocus && state.isReady) ...[
                InkWell(
                  onTap: () => _showTaskSelectDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
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
                              Icons.flag_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Hedef: $targetTitle',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Sayaç Bileşeni
              PomodoroTimer(state: state),
              const SizedBox(height: 24),

              // 5. Kontroller (Başlat, Duraklat, Devam Et, Bitir)
              PomodoroControls(
                onSelectTask: () => _showTaskSelectDialog(context),
              ),
              const SizedBox(height: 28),

              // 6. Günlük Özet Kartı (Tamamlanan Pomodoro & Gerçek Odak Dakikası)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 22,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${pomodoroCtrl.todayCompletedPomodoroCount}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tamamlanan',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 22,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${pomodoroCtrl.todayTotalFocusedMinutes} dk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bugün Odaklanılan',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 7. Pomodoro Geçmişim
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pomodoro Geçmişim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              PomodoroHistoryList(sessions: pomodoroCtrl.sessions),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
