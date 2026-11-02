import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: size * 0.58,
          color: AppColors.primary,
        ),
      ),
    );

    if (!showText) {
      return iconWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 12),
        const Text(
          'Alışkanlık Takibi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
            letterSpacing: -0.3,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          const Text(
            'Küçük adımlar, kalıcı alışkanlıklar.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
