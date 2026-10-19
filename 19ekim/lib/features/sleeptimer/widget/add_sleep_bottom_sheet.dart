import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class AddSleepBottomSheet extends StatefulWidget {
  const AddSleepBottomSheet({super.key, required this.onSave});

  final void Function(DateTime sleepTime, DateTime wakeTime, String quality)
      onSave;

  @override
  State<AddSleepBottomSheet> createState() => _AddSleepBottomSheetState();
}

class _AddSleepBottomSheetState extends State<AddSleepBottomSheet> {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 30);
  String _selectedQuality = 'Dinlendirici';

  static const List<String> _qualities = [
    'Dinlendirici',
    'Derin',
    'Hafif / Bölünmüş',
  ];

  Future<void> _pickTime(bool isSleepTime) async {
    final initial = isSleepTime ? _sleepTime : _wakeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColor.neonPurple,
              surface: AppColor.surface,
              onSurface: AppColor.textPrimary,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  void _handleSave() {
    final now = DateTime.now();
    final sleepDateTime = DateTime(
      now.year,
      now.month,
      now.day - (_sleepTime.hour > _wakeTime.hour ? 1 : 0),
      _sleepTime.hour,
      _sleepTime.minute,
    );
    final wakeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    widget.onSave(sleepDateTime, wakeDateTime, _selectedQuality);
    Navigator.of(context).pop();
  }

  int get _calculatedMinutes {
    final sleepMins = _sleepTime.hour * 60 + _sleepTime.minute;
    final wakeMins = _wakeTime.hour * 60 + _wakeTime.minute;
    if (wakeMins >= sleepMins) {
      return wakeMins - sleepMins;
    }
    return (24 * 60 - sleepMins) + wakeMins;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHeader(),
          const SizedBox(height: 18),
          _TimePickersRow(
            sleepTime: _sleepTime,
            wakeTime: _wakeTime,
            onPickSleep: () => _pickTime(true),
            onPickWake: () => _pickTime(false),
          ),
          const SizedBox(height: 16),
          _CalculatedDurationBanner(minutes: _calculatedMinutes),
          const SizedBox(height: 16),
          _QualityChips(
            qualities: _qualities,
            selected: _selectedQuality,
            onSelected: (q) => setState(() => _selectedQuality = q),
          ),
          const SizedBox(height: 20),
          _SaveButton(onPressed: _handleSave),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Uyku Kaydı Ekle',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColor.textMuted),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _TimePickersRow extends StatelessWidget {
  const _TimePickersRow({
    required this.sleepTime,
    required this.wakeTime,
    required this.onPickSleep,
    required this.onPickWake,
  });

  final TimeOfDay sleepTime;
  final TimeOfDay wakeTime;
  final VoidCallback onPickSleep;
  final VoidCallback onPickWake;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            title: 'Yatış Saati',
            time: sleepTime,
            icon: Icons.bedtime_outlined,
            onTap: onPickSleep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeButton(
            title: 'Uyanış Saati',
            time: wakeTime,
            icon: Icons.wb_sunny_outlined,
            onTap: onPickWake,
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.title,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final TimeOfDay time;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColor.neonPurple),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(color: AppColor.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              formatted,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatedDurationBanner extends StatelessWidget {
  const _CalculatedDurationBanner({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.neonPurple.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.neonPurple.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timelapse_rounded, color: AppColor.neonPurple, size: 18),
          const SizedBox(width: 8),
          Text(
            'Toplam Uyku: $hours saat $mins dakika',
            style: const TextStyle(
              color: AppColor.neonPurple,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityChips extends StatelessWidget {
  const _QualityChips({
    required this.qualities,
    required this.selected,
    required this.onSelected,
  });

  final List<String> qualities;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: qualities.map((q) {
        final isSelected = q == selected;
        return ChoiceChip(
          label: Text(q),
          selected: isSelected,
          onSelected: (_) => onSelected(q),
          selectedColor: AppColor.neonPurple,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : AppColor.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppColor.surfaceVariant,
          side: BorderSide(
            color: isSelected ? AppColor.neonPurple : AppColor.border,
          ),
        );
      }).toList(),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColor.neonPurple,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded),
        label: const Text(
          'Uykuyu Kaydet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
