import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../../../core/theme.dart';

/// Egzersiz ve yakılan kalori ilerleme kartı.
class WorkoutProgressCard extends StatelessWidget {
  final int burnedCalories;
  final int goalCalories;
  final int totalMinutes;

  const WorkoutProgressCard({
    super.key,
    required this.burnedCalories,
    required this.goalCalories,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (burnedCalories / goalCalories).clamp(0.0, 1.0);
    final int percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3370E000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Günlük Kalori Hedefi',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              Text(
                '$goalCalories kcal',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$burnedCalories',
                    style: const TextStyle(
                      color: AppTheme.neonLime,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Yakılan (kcal)',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              Container(width: 1, height: 40, color: AppTheme.border),
              Column(
                children: [
                  Text(
                    '$totalMinutes',
                    style: const TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Süre (Dk)',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: AppTheme.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonLime),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '%$percent Hedef Tamamlandı',
              style: const TextStyle(color: AppTheme.neonLime, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hızlı aktivite ekleme butonları.
class WorkoutQuickActions extends StatelessWidget {
  final void Function(String name, int duration, int calories) onAdd;

  const WorkoutQuickActions({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActivityBtn(
          title: 'Koşu',
          subtitle: '20 dk / 200 kcal',
          icon: Icons.directions_run,
          color: AppTheme.neonLime,
          onTap: () => onAdd('Koşu', 20, 200),
        ),
        const SizedBox(width: 12),
        _ActivityBtn(
          title: 'Bisiklet',
          subtitle: '30 dk / 250 kcal',
          icon: Icons.directions_bike,
          color: AppTheme.neonOrange,
          onTap: () => onAdd('Bisiklet', 30, 250),
        ),
        const SizedBox(width: 12),
        _ActivityBtn(
          title: 'Fitness',
          subtitle: '45 dk / 300 kcal',
          icon: Icons.fitness_center,
          color: AppTheme.neonCyan,
          onTap: () => onAdd('Fitness', 45, 300),
        ),
      ],
    );
  }
}

class _ActivityBtn extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActivityBtn({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Egzersiz kayıt satırı.
class WorkoutLogTile extends StatelessWidget {
  final WorkoutActivity item;
  final VoidCallback onDelete;

  const WorkoutLogTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: AppTheme.neonLime, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                '${item.durationMinutes} dakika',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '+${item.caloriesBurned} kcal',
            style: const TextStyle(color: AppTheme.neonLime, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.neonRed, size: 18),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
