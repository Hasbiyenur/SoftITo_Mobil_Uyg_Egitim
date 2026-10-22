import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/habit_color_service.dart';
import '../../../core/time/date_key.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_schedule.dart';
import '../../auth/auth_controller.dart';
import '../habit_controller.dart';
import '../services/schedule_service.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _intervalController;
  late final TextEditingController _targetValueController;
  late final TextEditingController _unitController;
  late final TextEditingController _stepController;

  late String _startDateKey;
  late String _targetTime;
  late String _counterType; // 'check' veya 'counter'
  late bool _reminderEnabled;
  late int _selectedIconCode;
  late int _selectedColorValue;

  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    final today = DateKey.today().value;

    if (h != null) {
      final s = h.latestSchedule;
      _titleController = TextEditingController(text: h.title);
      _descController = TextEditingController(text: h.description ?? '');
      _intervalController = TextEditingController(
        text: s.intervalDays.toString(),
      );
      _targetValueController = TextEditingController(
        text: s.targetValue.toString(),
      );
      _unitController = TextEditingController(text: s.unit);
      _stepController = TextEditingController(text: s.step.toString());
      _startDateKey = s.anchorDateKey;
      _targetTime = s.targetTime;
      _counterType = s.counterType;
      _reminderEnabled = s.reminderEnabled;
      _selectedIconCode = h.iconCodePoint;
      _selectedColorValue = h.colorValue;
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _intervalController = TextEditingController(text: '1');
      _targetValueController = TextEditingController(text: '10');
      _unitController = TextEditingController(text: 'sayfa');
      _stepController = TextEditingController(text: '1');
      _startDateKey = today;
      _targetTime = '21:00';
      _counterType = 'check';
      _reminderEnabled = true;
      _selectedIconCode = Icons.menu_book_rounded.codePoint;
      _selectedColorValue = HabitColorService.palette.first.toARGB32();
    }
  }

  bool _initializedColor = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedColor && widget.habit == null) {
      final habitCtrl = context.read<HabitController>();
      _selectedColorValue = HabitColorService.suggestNextColor(
        habitCtrl.allHabits,
      ).toARGB32();
      _initializedColor = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _intervalController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final currentDt = DateKey(_startDateKey).toLocalMidnight();
    final now = DateTime.now();
    final firstDate = widget.habit == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(2020, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDt.isBefore(firstDate) ? firstDate : currentDt,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _startDateKey = DateKey.fromDate(picked).value;
      });
    }
  }

  Future<void> _pickTargetTime() async {
    final parts = _targetTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 21,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _targetTime = '$h:$m';
      });
    }
  }

  List<String> _calculateNext3Days() {
    final interval = int.tryParse(_intervalController.text) ?? 1;
    if (interval < 1) return [];

    final tempSchedule = HabitSchedule(
      id: 'preview',
      habitId: 'preview',
      intervalDays: interval,
      anchorDateKey: _startDateKey,
      counterType: _counterType,
      targetValue: 1,
      effectiveFromDateKey: _startDateKey,
    );

    final todayKey = DateKey.today().value;
    final dates = _scheduleService.getNextScheduledDates(
      tempSchedule,
      todayKey.compareTo(_startDateKey) > 0 ? todayKey : _startDateKey,
      count: 3,
    );

    return dates.map((d) {
      final dt = DateKey(d).toLocalMidnight();
      return DateFormat('d MMMM', 'tr_TR').format(dt);
    }).toList();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final habitCtrl = context.read<HabitController>();
    final user = auth.currentUser;
    if (user == null) return;

    final interval = int.parse(_intervalController.text.trim());
    final isCounter = _counterType == 'counter';
    final targetVal = isCounter
        ? int.parse(_targetValueController.text.trim())
        : 1;
    final step = isCounter
        ? (int.tryParse(_stepController.text.trim()) ?? 1)
        : 1;
    final unit = isCounter ? _unitController.text.trim() : '';

    final todayKey = DateKey.today().value;

    await habitCtrl.saveHabit(
      userId: user.id,
      habitId: widget.habit?.id,
      title: _titleController.text,
      description: _descController.text,
      intervalDays: interval,
      startDateKey: _startDateKey,
      counterType: _counterType,
      targetValue: targetVal,
      unit: unit,
      step: step,
      targetTime: _targetTime,
      reminderEnabled: _reminderEnabled,
      iconCodePoint: _selectedIconCode,
      colorValue: _selectedColorValue,
      todayKey: todayKey,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.habit == null
              ? 'Alışkanlık başarıyla oluşturuldu.'
              : 'Alışkanlık güncellendi.',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;
    final nextDays = _calculateNext3Days();
    final isTargetTimeEarly =
        (int.tryParse(_targetTime.split(':')[0]) ?? 21) < 1;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Görevi Düzenle' : 'Görev Ekle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Plan değişikliklerin yarından itibaren geçerli olur. Önceki kayıtların korunur ve yeni plan için seri yeniden başlar.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 1. Görev adı
                AppTextField(
                  label: 'Görev Adı',
                  hint: 'Örn: Kitap Oku, Su İç, Spor Yap',
                  controller: _titleController,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Görev adı en az 2 karakter olmalıdır.';
                    }
                    if (v.trim().length > 60) {
                      return 'Görev adı en fazla 60 karakter olabilir.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Kısa açıklama
                AppTextField(
                  label: 'Kısa Açıklama (İsteğe bağlı)',
                  hint: 'Alışkanlığınla ilgili kısa bir not...',
                  controller: _descController,
                  maxLines: 2,
                  validator: (v) {
                    if (v != null && v.trim().length > 200) {
                      return 'Açıklama en fazla 200 karakter olabilir.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Kaç günde bir?
                AppTextField(
                  label: 'Kaç Günde Bir?',
                  hint: '1 (Her gün için 1 giriniz)',
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 365) {
                      return '1 ile 365 arasında bir sayı giriniz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 4. Başlangıç tarihi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Başlangıç Tarihi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickStartDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('d MMMM y, EEEE', 'tr_TR').format(
                                DateKey(_startDateKey).toLocalMidnight(),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Sonraki 3 gün önizlemesi
                if (nextDays.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Sonraki günler: ${nextDays.join(", ")}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // 5. Sayaç Türü (Tik atma veya Bar doldurma)
                const Text(
                  'Tamamlama Türü',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        title: 'Tik Atma',
                        subtitle: 'Tek tıkla tamamla',
                        icon: Icons.check_circle_outline_rounded,
                        isSelected: _counterType == 'check',
                        onTap: () => setState(() => _counterType = 'check'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeOption(
                        title: 'Bar Doldurma',
                        subtitle: 'Miktar sayacıyla',
                        icon: Icons.linear_scale_rounded,
                        isSelected: _counterType == 'counter',
                        onTap: () => setState(() => _counterType = 'counter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bar alanları (Hedef miktar, Birim, Adım)
                if (_counterType == 'counter') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 6. Hedef miktar
                        AppTextField(
                          label: 'Hedef Miktar',
                          hint: 'Örn: 20 (sayfa), 8 (bardak)',
                          controller: _targetValueController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (_counterType != 'counter') return null;
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1 || n > 10000) {
                              return '1 ile 10.000 arasında bir değer giriniz.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 7. Birim
                        AppTextField(
                          label: 'Birim',
                          hint: 'Örn: sayfa, bardak, dakika, adım',
                          controller: _unitController,
                          validator: (v) {
                            if (_counterType != 'counter') return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Lütfen bir birim giriniz.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 8. Artış adımı
                        AppTextField(
                          label: 'Artış Adımı',
                          hint: '1',
                          controller: _stepController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (_counterType != 'counter') return null;
                            final step = int.tryParse(v ?? '');
                            final target =
                                int.tryParse(_targetValueController.text) ??
                                10000;
                            if (step == null || step < 1 || step > target) {
                              return '1 ile hedef miktar arasında bir adım giriniz.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 9. Günlük hedef saati
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Günlük Hedef Saati',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickTargetTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _targetTime,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 10. Hatırlatma açık/kapalı
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _reminderEnabled,
                  activeTrackColor: AppColors.primary,
                  title: const Text(
                    'Uygulama İçi Hatırlatma',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isTargetTimeEarly
                        ? 'Hedef saatin 01:00\'den erken olduğu için hatırlatma önceki güne düşer.'
                        : 'Hedef saatinden 1 saat önce uygulama içinde hatırlatılır.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (val) => setState(() => _reminderEnabled = val),
                ),
                const SizedBox(height: 16),

                // 11. Simge seçimi
                const Text(
                  'Simge Seç',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppIcons.availableIcons.map((icon) {
                    final isSel = icon.codePoint == _selectedIconCode;
                    return InkWell(
                      onTap: () =>
                          setState(() => _selectedIconCode = icon.codePoint),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primaryContainer
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : AppColors.outline,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: isSel
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 12. Soft renk seçimi
                const Text(
                  'Vurgu Rengi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: HabitColorService.palette.map((col) {
                    final isSel = col.toARGB32() == _selectedColorValue;
                    return InkWell(
                      onTap: () =>
                          setState(() => _selectedColorValue = col.toARGB32()),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? Colors.black87 : Colors.white,
                            width: isSel ? 3 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: col.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSel
                            ? const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // 13. Kaydet butonu
                PrimaryButton(text: 'Kaydet', onPressed: _handleSave),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
