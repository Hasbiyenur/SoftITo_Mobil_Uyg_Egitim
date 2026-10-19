import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WaterTrackerCard extends StatelessWidget {
  final int currentWater;
  final int dailyGoal;

  const WaterTrackerCard({
    super.key,
    required this.currentWater,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (dailyGoal > 0 ? (currentWater / dailyGoal) : 0.0).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    final primaryAqua = AppColors.primaryAquaOf(context);
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
                      Icons.water_drop_rounded,
                      color: primaryAqua,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Günlük Hidrasyon',
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
                    color: primaryAqua.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryAqua.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '%$percentage',
                    style: TextStyle(
                      color: primaryAqua,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Dairesel Gösterge
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
                    valueColor: AlwaysStoppedAnimation<Color>(primaryAqua),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currentWater',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'ml',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryAqua,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hedef: $dailyGoal ml',
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
            Text(
              currentWater >= dailyGoal
                  ? '🎉 Harika! Günlük su hedefini başarıyla tamamladın!'
                  : 'Hedefe ulaşmak için ${(dailyGoal - currentWater).clamp(0, 99999)} ml daha su içmelisin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: currentWater >= dailyGoal
                    ? AppColors.energyLimeOf(context)
                    : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
