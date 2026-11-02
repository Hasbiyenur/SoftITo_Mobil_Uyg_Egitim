import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Sevimli, soft temaya uygun filiz karakteri maskotu.
/// Flutter CustomPainter ile çizilir; harici görsel gerektirmez.
class MotivationMascot extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const MotivationMascot({super.key, required this.onTap, this.size = 62.0});

  @override
  State<MotivationMascot> createState() => _MotivationMascotState();
}

class _MotivationMascotState extends State<MotivationMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

    return Semantics(
      button: true,
      label: 'Motivasyon Maskotu',
      hint: 'Yeni bir motivasyon cümlesi için dokun',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, reduceMotion ? 0 : _bounceAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 2,
              ),
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _SproutPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sevimli filiz karakterinin vektörel çizimi
class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Minik pastel saksı / taban taşı
    final potPaint = Paint()
      ..color = const Color(0xFFD69E7B)
      ..style = PaintingStyle.fill;

    final potRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.28),
        width: size.width * 0.44,
        height: size.height * 0.26,
      ),
      const Radius.circular(7),
    );
    canvas.drawRRect(potRect, potPaint);

    // Saksı kenar şeridi
    final rimPaint = Paint()
      ..color = const Color(0xFFC78C68)
      ..style = PaintingStyle.fill;
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.17),
        width: size.width * 0.50,
        height: size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rimRect, rimPaint);

    // 2. Saksıdaki minik tatlı yüz (gözler ve gülümseme)
    final eyePaint = Paint()
      ..color = const Color(0xFF3E2D23)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 5.5, cy + size.height * 0.28), 1.8, eyePaint);
    canvas.drawCircle(Offset(cx + 5.5, cy + size.height * 0.28), 1.8, eyePaint);

    // Pembe yanaklar
    final blushPaint = Paint()
      ..color = const Color(0xFFE8958D).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx - 8.5, cy + size.height * 0.31),
      2.2,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(cx + 8.5, cy + size.height * 0.31),
      2.2,
      blushPaint,
    );

    // Minik gülümseme
    final smilePaint = Paint()
      ..color = const Color(0xFF3E2D23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - 2.5, cy + size.height * 0.32)
      ..quadraticBezierTo(
        cx,
        cy + size.height * 0.35,
        cx + 2.5,
        cy + size.height * 0.32,
      );
    canvas.drawPath(smilePath, smilePaint);

    // 3. Gövde / Filiz sapı
    final stemPaint = Paint()
      ..color = const Color(0xFF4C8C5B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(cx, cy + size.height * 0.14)
      ..quadraticBezierTo(
        cx - 1,
        cy - size.height * 0.04,
        cx,
        cy - size.height * 0.16,
      );
    canvas.drawPath(stemPath, stemPaint);

    // 4. Sağ Yaprak (Neşeli ve dolgun)
    final leafPaintRight = Paint()
      ..color = const Color(0xFF5CA36D)
      ..style = PaintingStyle.fill;

    final rightLeaf = Path()
      ..moveTo(cx, cy - size.height * 0.08)
      ..cubicTo(
        cx + size.width * 0.22,
        cy - size.height * 0.22,
        cx + size.width * 0.28,
        cy - size.height * 0.02,
        cx,
        cy - size.height * 0.02,
      );
    canvas.drawPath(rightLeaf, leafPaintRight);

    // 5. Sol Yaprak (Hafif yukarı bakan)
    final leafPaintLeft = Paint()
      ..color = const Color(0xFF6FB881)
      ..style = PaintingStyle.fill;

    final leftLeaf = Path()
      ..moveTo(cx, cy - size.height * 0.12)
      ..cubicTo(
        cx - size.width * 0.24,
        cy - size.height * 0.26,
        cx - size.width * 0.26,
        cy - size.height * 0.05,
        cx,
        cy - size.height * 0.05,
      );
    canvas.drawPath(leftLeaf, leafPaintLeft);

    // Tepe minik tomurcuk ışığı
    final budPaint = Paint()
      ..color = const Color(0xFFA6E3B5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - size.height * 0.17), 1.8, budPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
