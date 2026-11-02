import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorkoutCard extends StatelessWidget {
  final Function({
    required String activityName,
    required int durationMinutes,
    required int caloriesBurned,
    required String iconType,
  }) onAddWorkout;
  final VoidCallback onReset;

  const WorkoutCard({
    super.key,
    required this.onAddWorkout,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final energyCoral = AppColors.energyCoralOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivite Ekle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: onReset,
              icon: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: energyCoral,
              ),
              label: Text(
                'Sıfırla',
                style: TextStyle(
                  color: energyCoral,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildActivityChip(
              context: context,
              name: 'Koşu',
              duration: 30,
              calories: 300,
              icon: Icons.directions_run_rounded,
              iconType: 'run',
              color: AppColors.energyOrangeOf(context),
            ),
            const SizedBox(width: 8),
            _buildActivityChip(
              context: context,
              name: 'Bisiklet',
              duration: 45,
              calories: 350,
              icon: Icons.directions_bike_rounded,
              iconType: 'bike',
              color: AppColors.energyLimeOf(context),
            ),
            const SizedBox(width: 8),
            _buildActivityChip(
              context: context,
              name: 'Yüzme',
              duration: 30,
              calories: 280,
              icon: Icons.pool_rounded,
              iconType: 'swim',
              color: AppColors.primaryAquaOf(context),
            ),
            const SizedBox(width: 8),
            _buildActivityChip(
              context: context,
              name: 'Fitness',
              duration: 40,
              calories: 220,
              icon: Icons.fitness_center_rounded,
              iconType: 'gym',
              color: AppColors.energyCoralOf(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityChip({
    required BuildContext context,
    required String name,
    required int duration,
    required int calories,
    required IconData icon,
    required String iconType,
    required Color color,
  }) {
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Expanded(
      child: InkWell(
        onTap: () => onAddWorkout(
          activityName: name,
          durationMinutes: duration,
          caloriesBurned: calories,
          iconType: iconType,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$duration dk',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Text(
                '$calories kcal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
