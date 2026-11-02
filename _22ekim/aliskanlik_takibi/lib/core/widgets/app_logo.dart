import 'package:flutter/material.dart';

import 'sweet_animated_logo.dart';

/// Alışkanlık Takibi uygulaması logosu.
///
/// Başlık ve alt başlıkla birlikte ya da yalnızca sevimli canlı logo
/// rozeti (`SweetAnimatedLogo`) olarak görüntülenebilir.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final bool isAnimated;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showSubtitle = true,
    this.isAnimated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final logoWidget = SweetAnimatedLogo(
      size: size,
      interactive: true,
      onTap: onTap,
      autoAnimate: isAnimated,
    );

    if (!showText) {
      return logoWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        const SizedBox(height: 12),
        Text(
          'Alışkanlık Takibi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            'Küçük adımlar, kalıcı alışkanlıklar.',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
