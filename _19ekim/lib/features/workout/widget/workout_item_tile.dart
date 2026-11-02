import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';
import '../models/workout_model.dart';

class WorkoutItemTile extends StatelessWidget {
  const WorkoutItemTile({
    super.key,
    required this.workout,
    required this.onDelete,
  });

  final WorkoutModel workout;
  final VoidCallback onDelete;

  IconData _resolveIcon(WorkoutType type) {
    return switch (type) {
      WorkoutType.running => Icons.directions_run_rounded,
      WorkoutType.cycling => Icons.directions_bike_rounded,
      WorkoutType.weightlifting => Icons.fitness_center_rounded,
      WorkoutType.swimming => Icons.pool_rounded,
      WorkoutType.hiit => Icons.flash_on_rounded,
      WorkoutType.walking => Icons.directions_walk_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.neonLime.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_resolveIcon(workout.type),
                color: AppColor.neonLime, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type.label,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${workout.durationMinutes} dakika • ${workout.caloriesBurned} kcal',
                  style: const TextStyle(
                    color: AppColor.neonAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColor.neonRose, size: 20),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
