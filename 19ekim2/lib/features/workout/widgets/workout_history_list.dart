import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/workout_model.dart';

class WorkoutHistoryList extends StatelessWidget {
  final List<WorkoutModel> workouts;
  final Function(String id) onDelete;

  const WorkoutHistoryList({
    super.key,
    required this.workouts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünkü Egzersiz Geçmişi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (workouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                'Henüz egzersiz kaydı bulunmuyor.',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final timeStr =
                  '${workout.timestamp.hour.toString().padLeft(2, '0')}:${workout.timestamp.minute.toString().padLeft(2, '0')}';

              IconData icon = Icons.fitness_center_rounded;
              Color color = AppColors.energyLimeOf(context);

              if (workout.iconType == 'run') {
                icon = Icons.directions_run_rounded;
                color = AppColors.energyOrangeOf(context);
              } else if (workout.iconType == 'bike') {
                icon = Icons.directions_bike_rounded;
                color = AppColors.energyLimeOf(context);
              } else if (workout.iconType == 'swim') {
                icon = Icons.pool_rounded;
                color = AppColors.primaryAquaOf(context);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.activityName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            '$timeStr • ${workout.durationMinutes} dakika',
                            style: TextStyle(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${workout.caloriesBurned} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: textMuted,
                      ),
                      onPressed: () => onDelete(workout.id),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
