import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProgressCounter extends StatelessWidget {
  final int currentValue;
  final int targetValue;
  final String unit;
  final int step;
  final bool isCompleted;
  final Color accentColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProgressCounter({
    super.key,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.step,
    required this.isCompleted,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = targetValue <= 0
        ? 0.0
        : (currentValue / targetValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentValue / $targetValue $unit'.trim(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppColors.completedText
                    : AppColors.onSurface,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepButton(
                  icon: Icons.remove_rounded,
                  onPressed: currentValue > 0 ? onDecrement : null,
                  tooltip: 'Azalt (-$step)',
                ),
                const SizedBox(width: 8),
                _buildStepButton(
                  icon: Icons.add_rounded,
                  onPressed: currentValue < targetValue ? onIncrement : null,
                  isPrimary: true,
                  tooltip: 'Arttır (+$step)',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? AppColors.success : accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    String? tooltip,
  }) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: enabled
                ? (isPrimary
                      ? accentColor.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant)
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled
                  ? (isPrimary
                        ? accentColor.withValues(alpha: 0.3)
                        : AppColors.outline)
                  : AppColors.outlineVariant,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? (isPrimary ? accentColor : AppColors.onSurface)
                : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
