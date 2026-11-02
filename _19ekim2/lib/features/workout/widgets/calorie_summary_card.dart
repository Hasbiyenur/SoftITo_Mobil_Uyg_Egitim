import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CalorieSummaryCard extends StatelessWidget {
  final int totalCalories;
  final int goalCalories;
  final int totalMinutes;

  const CalorieSummaryCard({
    super.key,
    required this.totalCalories,
    required this.goalCalories,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (goalCalories > 0 ? (totalCalories / goalCalories) : 0.0).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    final energyOrange = AppColors.energyOrangeOf(context);
    final energyLime = AppColors.energyLimeOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final border = AppColors.borderOf(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.surfaceOf(context),
              AppColors.surfaceElevatedOf(context).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: energyOrange,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kalori ve Aktivite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: energyOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: energyOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '%$percentage',
                    style: TextStyle(
                      color: energyOrange,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    backgroundColor: border,
                    valueColor: AlwaysStoppedAnimation<Color>(energyLime),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCalories',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: energyLime,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hedef: $goalCalories kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat(
                  context: context,
                  icon: Icons.timer_outlined,
                  label: 'Süre',
                  value: '$totalMinutes dk',
                  color: AppColors.primaryAquaOf(context),
                ),
                Container(width: 1, height: 30, color: border),
                _buildMiniStat(
                  context: context,
                  icon: Icons.bolt_rounded,
                  label: 'Kalan',
                  value: '${(goalCalories - totalCalories).clamp(0, 99999)} kcal',
                  color: AppColors.energyCoralOf(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMutedOf(context),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
