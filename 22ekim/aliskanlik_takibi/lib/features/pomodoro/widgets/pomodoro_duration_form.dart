import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/pomodoro_preferences.dart';
import '../pomodoro_controller.dart';

class PomodoroDurationForm extends StatefulWidget {
  const PomodoroDurationForm({super.key});

  @override
  State<PomodoroDurationForm> createState() => _PomodoroDurationFormState();
}

class _PomodoroDurationFormState extends State<PomodoroDurationForm> {
  late TextEditingController _focusController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;

  String? _focusError;
  String? _shortBreakError;
  String? _longBreakError;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PomodoroController>().preferences;
    _focusController = TextEditingController(text: '${prefs.focusMinutes}');
    _shortBreakController = TextEditingController(
      text: '${prefs.shortBreakMinutes}',
    );
    _longBreakController = TextEditingController(
      text: '${prefs.longBreakMinutes}',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prefs = context.watch<PomodoroController>().preferences;
    // Eğer kullanıcı aktif düzenleme yapmıyorsa controller'ları güncelle
    if (!_focusController.selection.isValid) {
      _focusController.text = '${prefs.focusMinutes}';
    }
    if (!_shortBreakController.selection.isValid) {
      _shortBreakController.text = '${prefs.shortBreakMinutes}';
    }
    if (!_longBreakController.selection.isValid) {
      _longBreakController.text = '${prefs.longBreakMinutes}';
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _focusError = PomodoroPreferences.validateFocusMinutes(
        _focusController.text,
      );
      _shortBreakError = PomodoroPreferences.validateShortBreakMinutes(
        _shortBreakController.text,
      );

      final shortVal = int.tryParse(_shortBreakController.text.trim()) ?? 5;
      _longBreakError = PomodoroPreferences.validateLongBreakMinutes(
        _longBreakController.text,
        shortVal,
      );
    });

    if (_focusError == null &&
        _shortBreakError == null &&
        _longBreakError == null) {
      final focus = int.parse(_focusController.text.trim());
      final shortBreak = int.parse(_shortBreakController.text.trim());
      final longBreak = int.parse(_longBreakController.text.trim());

      final pomodoroCtrl = context.read<PomodoroController>();
      pomodoroCtrl.saveCustomDurations(
        focusMinutes: focus,
        shortBreakMinutes: shortBreak,
        longBreakMinutes: longBreak,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Süre tercihleri başarıyla kaydedildi.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _focusController.text = '25';
      _shortBreakController.text = '5';
      _longBreakController.text = '15';
      _focusError = null;
      _shortBreakError = null;
      _longBreakError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Süreler 25 / 5 / 15 olarak dolduruldu. Değişiklikleri uygulamak için "Süreleri Kaydet"e dokunun.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _adjustValue(
    TextEditingController controller,
    int delta,
    int min,
    int max,
  ) {
    final current = int.tryParse(controller.text.trim()) ?? min;
    final next = (current + delta).clamp(min, max);
    setState(() {
      controller.text = '$next';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroCtrl = context.watch<PomodoroController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık satırı (Aç/Kapa imkanı ile düzenli görünüm)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Süre Ayarları',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${pomodoroCtrl.preferences.focusMinutes} / ${pomodoroCtrl.preferences.shortBreakMinutes} / ${pomodoroCtrl.preferences.longBreakMinutes} dk',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // 1. Çalışma Süresi Alanı (1–180 dk)
              _buildDurationField(
                context: context,
                label: 'Çalışma Süresi (dakika)',
                hintText: 'Örn: 25 (1–180 dk)',
                controller: _focusController,
                errorText: _focusError,
                onDecrement: () => _adjustValue(_focusController, -1, 1, 180),
                onIncrement: () => _adjustValue(_focusController, 1, 1, 180),
              ),
              const SizedBox(height: 14),

              // 2. Kısa Mola Alanı (1–60 dk)
              _buildDurationField(
                context: context,
                label: 'Kısa Mola (dakika)',
                hintText: 'Örn: 5 (1–60 dk)',
                controller: _shortBreakController,
                errorText: _shortBreakError,
                onDecrement: () =>
                    _adjustValue(_shortBreakController, -1, 1, 60),
                onIncrement: () =>
                    _adjustValue(_shortBreakController, 1, 1, 60),
              ),
              const SizedBox(height: 14),

              // 3. Uzun Mola Alanı (1–120 dk, kısa moladan kısa olamaz)
              _buildDurationField(
                context: context,
                label: 'Uzun Mola (dakika)',
                hintText: 'Örn: 15 (1–120 dk)',
                controller: _longBreakController,
                errorText: _longBreakError,
                onDecrement: () =>
                    _adjustValue(_longBreakController, -1, 1, 120),
                onIncrement: () =>
                    _adjustValue(_longBreakController, 1, 1, 120),
              ),
              const SizedBox(height: 14),

              // Devam eden aşama uyarısı
              if (pomodoroCtrl.noticeMessage != null ||
                  !pomodoroCtrl.state.isReady) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkWarning : AppColors.warning)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkWarning
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pomodoroCtrl.noticeMessage ??
                              'Yeni süreler sonraki aşamalarda kullanılacak.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkWarning
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Butonlar: Süreleri Kaydet & Varsayılana Döndür
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _validateAndSave,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Süreleri Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _resetToDefaults,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outline),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Varsayılana',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDurationField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? errorText,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Eksi Butonu
            IconButton.filledTonal(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove_rounded, size: 18),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(40, 40),
              ),
            ),
            const SizedBox(width: 8),

            // Giriş Alanı
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: errorText != null
                          ? (isDark ? AppColors.darkError : AppColors.error)
                          : colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Artı Butonu
            IconButton.filledTonal(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_rounded, size: 18),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(40, 40),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkError : AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
