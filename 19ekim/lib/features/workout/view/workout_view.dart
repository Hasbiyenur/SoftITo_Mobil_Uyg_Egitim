import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../controller/workout_controller.dart';
import '../widget/add_workout_bottom_sheet.dart';
import '../widget/workout_item_tile.dart';
import '../widget/workout_summary_card.dart';

class WorkoutView extends StatelessWidget {
  const WorkoutView({
    super.key,
    required this.controller,
  });

  final WorkoutController controller;

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWorkoutBottomSheet(
        onSave: (type, duration) {
          controller.addWorkout(type: type, durationMinutes: duration);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutSummaryCard(
                totalCalories: controller.totalCaloriesBurned,
                totalMinutes: controller.totalDurationMinutes,
                activityCount: controller.workouts.length,
              ),
              const SizedBox(height: 16),
              _AddWorkoutTriggerButton(onTap: () => _showAddDialog(context)),
              const SizedBox(height: 24),
              _WorkoutHeader(onReset: controller.resetToday),
              const SizedBox(height: 12),
              _WorkoutListSection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _AddWorkoutTriggerButton extends StatelessWidget {
  const _AddWorkoutTriggerButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.neonLime, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded, color: AppColor.neonLime),
        label: const Text(
          'Yeni Egzersiz Ekle',
          style: TextStyle(
            color: AppColor.neonLime,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tamamlanan Egzersizler',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColor.textMuted),
          label: const Text(
            'Sıfırla',
            style: TextStyle(color: AppColor.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _WorkoutListSection extends StatelessWidget {
  const _WorkoutListSection({required this.controller});

  final WorkoutController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text(
          'Bugün henüz bir egzersiz eklemedin. Hareket zamanı!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColor.textMuted),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.workouts.length,
      itemBuilder: (context, index) {
        final workout = controller.workouts[index];
        return WorkoutItemTile(
          key: ValueKey(workout.id),
          workout: workout,
          onDelete: () => controller.removeWorkout(workout.id),
        );
      },
    );
  }
}
