import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.totalCalories,
    required this.totalMinutes,
    required this.activityCount,
  });

  final int totalCalories;
  final int totalMinutes;
  final int activityCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatMetric(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColor.neonAmber,
              label: 'Yakılan',
              value: '$totalCalories kcal',
            ),
            _StatDivider(),
            _StatMetric(
              icon: Icons.timer_outlined,
              iconColor: AppColor.neonLime,
              label: 'Süre',
              value: '$totalMinutes dk',
            ),
            _StatDivider(),
            _StatMetric(
              icon: Icons.fitness_center_rounded,
              iconColor: AppColor.neonCyan,
              label: 'Egzersiz',
              value: '$activityCount adet',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColor.border,
    );
  }
}

class _StatMetric extends StatelessWidget {
  const _StatMetric({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColor.textMuted, fontSize: 12)),
      ],
    );
  }
}
