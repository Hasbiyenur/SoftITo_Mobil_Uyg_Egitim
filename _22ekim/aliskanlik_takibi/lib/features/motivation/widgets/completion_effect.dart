import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../completion_feedback_controller.dart';

/// Görev tamamlandığında yumuşak parıltı (sparkle) veya sıcak alev (flame) animasyonu.
/// Dokunmaları engellemez (IgnorePointer) ve neon/göz yorucu öğeler içermez.
class CompletionEffect extends StatefulWidget {
  final CelebrationType type;

  const CompletionEffect({super.key, required this.type});

  @override
  State<CompletionEffect> createState() => _CompletionEffectState();
}

class _CompletionEffectState extends State<CompletionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (reduceMotion) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _EffectPainter(
              progress: _controller.value,
              isSparkle: widget.type == CelebrationType.sparkle,
            ),
          );
        },
      ),
    );
  }
}

class _EffectPainter extends CustomPainter {
  final double progress;
  final bool isSparkle;

  _EffectPainter({required this.progress, required this.isSparkle});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final cx = size.width / 2;
    // Ekranın alt-orta kısmından veya hafif yukarısından yayılma
    final cy = size.height * 0.45;

    // Parıltı Efekti (Pastel yıldızlar ve ışıltılar)
    if (isSparkle) {
      final colors = [
        const Color(0xFFD49B35).withValues(alpha: (1 - progress)), // Altın
        const Color(0xFF3B6E52).withValues(alpha: (1 - progress)), // Adaçayı
        const Color(0xFF7C6DAF).withValues(alpha: (1 - progress)), // Lavanta
        const Color(0xFF4A7298).withValues(alpha: (1 - progress)), // Soft Mavi
      ];

      const count = 16;
      for (var i = 0; i < count; i++) {
        final angle = (i * (2 * math.pi / count)) + (progress * 0.5);
        final distance = progress * (70 + (i % 4) * 25);
        final x = cx + math.cos(angle) * distance;
        final y =
            cy +
            math.sin(angle) * distance -
            (progress * 30); // Hafif yukarı yükselir

        final color = colors[i % colors.length];
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final radius = (3.5 - (progress * 2.0)).clamp(0.5, 4.0);

        // Yıldız şeklinde veya minik parıltı çemberi
        if (i % 2 == 0) {
          _drawStar(canvas, Offset(x, y), radius * 1.5, paint);
        } else {
          canvas.drawCircle(Offset(x, y), radius, paint);
        }
      }
    } else {
      // Alev Efekti (Sıcak pastel turuncu, terrakotta ve bal tonları)
      final flameColors = [
        const Color(0xFFD97757).withValues(alpha: (1 - progress)), // Terrakotta
        const Color(0xFFE28A6E).withValues(alpha: (1 - progress)), // Şeftali
        const Color(0xFFD49B35).withValues(alpha: (1 - progress)), // Bal Sarısı
      ];

      const count = 14;
      for (var i = 0; i < count; i++) {
        final spreadX = (math.sin(i * 1.5) * 45) * progress;
        final riseY = progress * 90; // Yukarı doğru alev yükselişi
        final x = cx + spreadX;
        final y = cy - riseY + (i % 3) * 10;

        final color = flameColors[i % flameColors.length];
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        final radius = (4.5 - (progress * 3.0)).clamp(0.8, 5.0);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      path.moveTo(center.dx, center.dy);
      path.lineTo(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
    }
    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _EffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
