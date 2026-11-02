import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HydrationTipCard extends StatelessWidget {
  const HydrationTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final energyLime = AppColors.energyLimeOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: energyLime,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hidrasyon İpucu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: energyLime,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sabah uyandığında içilen 1 bardak ılık su, metabolizmayı %24 hızlandırır ve toksinlerin atılmasına destek olur.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
