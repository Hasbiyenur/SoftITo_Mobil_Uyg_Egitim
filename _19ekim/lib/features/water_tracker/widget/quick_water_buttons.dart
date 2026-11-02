import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class QuickWaterButtons extends StatelessWidget {
  const QuickWaterButtons({
    super.key,
    required this.onAddWater,
  });

  final void Function(int amount, String name) onAddWater;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickBtn(
            label: '200 ml',
            subtitle: 'Bardak',
            icon: Icons.local_drink_rounded,
            onTap: () => onAddWater(200, 'Bardak'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickBtn(
            label: '330 ml',
            subtitle: 'Kupa',
            icon: Icons.coffee_rounded,
            onTap: () => onAddWater(330, 'Kupa'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickBtn(
            label: '500 ml',
            subtitle: 'Şişe',
            icon: Icons.sports_bar_rounded,
            onTap: () => onAddWater(500, 'Şişe'),
          ),
        ),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColor.neonCyan, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
