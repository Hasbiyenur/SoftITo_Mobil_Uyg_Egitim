import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../models/workout_model.dart';

class AddWorkoutBottomSheet extends StatefulWidget {
  const AddWorkoutBottomSheet({super.key, required this.onSave});

  final void Function(WorkoutType type, int durationMinutes) onSave;

  @override
  State<AddWorkoutBottomSheet> createState() => _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends State<AddWorkoutBottomSheet> {
  WorkoutType _selectedType = WorkoutType.running;
  final TextEditingController _durationController =
      TextEditingController(text: '30');

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final minutes = int.tryParse(_durationController.text) ?? 0;
    if (minutes > 0) {
      widget.onSave(_selectedType, minutes);
      Navigator.of(context).pop();
    }
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
          const SizedBox(height: 16),
          _WorkoutTypeChips(
            selectedType: _selectedType,
            onSelected: (type) => setState(() => _selectedType = type),
          ),
          const SizedBox(height: 20),
          _DurationInput(controller: _durationController),
          const SizedBox(height: 20),
          _SaveButton(
            type: _selectedType,
            controller: _durationController,
            onPressed: _handleSave,
          ),
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
          'Egzersiz Ekle',
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

class _WorkoutTypeChips extends StatelessWidget {
  const _WorkoutTypeChips({
    required this.selectedType,
    required this.onSelected,
  });

  final WorkoutType selectedType;
  final ValueChanged<WorkoutType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WorkoutType.values.map((type) {
        final isSelected = type == selectedType;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (_) => onSelected(type),
          selectedColor: AppColor.neonLime,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : AppColor.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppColor.surfaceVariant,
          side: BorderSide(
            color: isSelected ? AppColor.neonLime : AppColor.border,
          ),
        );
      }).toList(),
    );
  }
}

class _DurationInput extends StatelessWidget {
  const _DurationInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Süre (Dakika)',
        labelStyle: const TextStyle(color: AppColor.textSecondary),
        suffixText: 'dk',
        suffixStyle: const TextStyle(color: AppColor.neonLime),
        filled: true,
        fillColor: AppColor.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.neonLime),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.type,
    required this.controller,
    required this.onPressed,
  });

  final WorkoutType type;
  final TextEditingController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColor.neonLime,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded),
        label: const Text(
          'Kaydet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
