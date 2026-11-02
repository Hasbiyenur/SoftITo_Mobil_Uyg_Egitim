import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickWaterButtons extends StatelessWidget {
  final Function(int amount, String label) onAdd;
  final VoidCallback onReset;

  const QuickWaterButtons({
    super.key,
    required this.onAdd,
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
              'Hızlı Ekle',
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
            _buildOption(
              context: context,
              icon: Icons.local_drink_rounded,
              amount: 200,
              label: 'Bardak',
            ),
            const SizedBox(width: 10),
            _buildOption(
              context: context,
              icon: Icons.coffee_rounded,
              amount: 330,
              label: 'Kupa',
            ),
            const SizedBox(width: 10),
            _buildOption(
              context: context,
              icon: Icons.sports_bar_rounded,
              amount: 500,
              label: 'Matara',
            ),
            const SizedBox(width: 10),
            _buildOption(
              context: context,
              icon: Icons.water_damage_rounded,
              amount: 1000,
              label: 'Sürahi',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required int amount,
    required String label,
  }) {
    final primaryAqua = AppColors.primaryAquaOf(context);
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textMuted = AppColors.textMutedOf(context);

    return Expanded(
      child: InkWell(
        onTap: () => onAdd(amount, label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: primaryAqua, size: 26),
              const SizedBox(height: 6),
              Text(
                '+$amount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Text(
                'ml',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
