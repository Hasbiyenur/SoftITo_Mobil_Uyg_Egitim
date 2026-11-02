import 'package:flutter/material.dart';
import '../models/water_tracker_model.dart';
import '../../../core/theme.dart';

/// Hidrasyon ilerlemesini gösteren Obsidian & Neon temalı dairesel kart.
class WaterProgressCard extends StatelessWidget {
  final int current;
  final int goal;

  const WaterProgressCard({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (current / goal).clamp(0.0, 1.0);
    final int percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3300D2FF),
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
                'Günlük Hedef',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              Text(
                '$goal ml',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonCyan),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'ml',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '%$percent Tamamlandı',
            style: const TextStyle(
              color: AppTheme.neonAqua,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hızlı su ekleme buton grubu.
class WaterQuickActions extends StatelessWidget {
  final ValueChanged<int> onAdd;

  const WaterQuickActions({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickButton(
          title: 'Bardak',
          amount: 200,
          icon: Icons.local_cafe_outlined,
          onTap: () => onAdd(200),
        ),
        const SizedBox(width: 12),
        _QuickButton(
          title: 'Kupa',
          amount: 330,
          icon: Icons.local_drink_outlined,
          onTap: () => onAdd(330),
        ),
        const SizedBox(width: 12),
        _QuickButton(
          title: 'Matara',
          amount: 500,
          icon: Icons.water_drop_outlined,
          onTap: () => onAdd(500),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickButton({
    required this.title,
    required this.amount,
    required this.icon,
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
          splashColor: const Color(0x3300D2FF),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppTheme.neonCyan, size: 24),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '+$amount ml',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Geçmiş kayıt satırı atomik bileşeni.
class WaterLogTile extends StatelessWidget {
  final WaterLogItem item;
  final VoidCallback onDelete;

  const WaterLogTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: AppTheme.neonCyan, size: 18),
          const SizedBox(width: 12),
          Text(
            '+${item.amountMl} ml',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.neonRed,
              size: 18,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
