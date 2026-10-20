import 'package:flutter/material.dart';

class RentoLogo extends StatelessWidget {
  final double size;
  final double? fontSize;
  final bool showText;
  final bool isVertical;
  final String? subtitle;

  const RentoLogo({
    super.key,
    this.size = 36,
    this.fontSize,
    this.showText = true,
    this.isVertical = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    // Logo Amblemi
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB), // Modern Blue
            Color(0xFF06B6D4), // Cyan Accent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // İkon Arka Vurgusu
            Icon(
              Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
            // Dinamik sağ üst hız/anahtar noktası
            Positioned(
              right: size * 0.16,
              top: size * 0.16,
              child: Container(
                width: size * 0.15,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!showText) {
      return iconWidget;
    }

    final double effectiveFontSize = fontSize ?? (size * 0.55);

    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Ren',
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        Text(
          'to',
          style: TextStyle(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: primary,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 2),
          width: effectiveFontSize * 0.25,
          height: effectiveFontSize * 0.25,
          decoration: const BoxDecoration(
            color: Color(0xFF06B6D4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(height: size * 0.22),
          titleWidget,
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: effectiveFontSize * 0.38,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget,
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
