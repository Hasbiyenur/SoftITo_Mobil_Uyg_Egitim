import 'package:flutter/material.dart';

import '../../data/models/avatar_option.dart';
import '../theme/app_colors.dart';

/// 8 hazır avatarı (4 insan, 4 hayvan) her boyutta, temiz, pastel ve vektörel olarak
/// çizen ve gösteren ortak avatar bileşeni.
class AppAvatar extends StatelessWidget {
  final String avatarId;
  final double size;
  final bool isSelected;
  final bool showBorder;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.isSelected = false,
    this.showBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final validOption = AvatarOption.byId(avatarId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBgColor(validOption.id, isDark),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : (showBorder
                    ? (isDark ? AppColors.darkOutline : AppColors.outline)
                    : Colors.transparent),
          width: isSelected ? 2.5 : 1.2,
        ),
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _AvatarPainter(avatarId: validOption.id, isDark: isDark),
        ),
      ),
    );

    if (isSelected) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: (size * 0.28).clamp(12.0, 20.0),
                color: isDark ? AppColors.darkOnPrimary : Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatarWidget);
    }

    return avatarWidget;
  }

  Color _getBgColor(String id, bool isDark) {
    if (isDark) {
      switch (id) {
        case 'fox':
          return const Color(0xFF382A22);
        case 'cat':
          return const Color(0xFF352B38);
        case 'dog':
          return const Color(0xFF332F24);
        case 'panda':
          return const Color(0xFF26332D);
        case 'human_01':
          return const Color(0xFF243338);
        case 'human_02':
          return const Color(0xFF293038);
        case 'human_03':
          return const Color(0xFF25382E);
        case 'human_04':
          return const Color(0xFF382933);
        default:
          return const Color(0xFF26332D);
      }
    } else {
      switch (id) {
        case 'fox':
          return const Color(0xFFFFE6D6);
        case 'cat':
          return const Color(0xFFF3E5F5);
        case 'dog':
          return const Color(0xFFFFF3CD);
        case 'panda':
          return const Color(0xFFE2EBE5);
        case 'human_01':
          return const Color(0xFFE1F0F5);
        case 'human_02':
          return const Color(0xFFE8EEF8);
        case 'human_03':
          return const Color(0xFFE2F3E7);
        case 'human_04':
          return const Color(0xFFF9E4EC);
        default:
          return const Color(0xFFE2EBE5);
      }
    }
  }
}

class _AvatarPainter extends CustomPainter {
  final String avatarId;
  final bool isDark;

  _AvatarPainter({required this.avatarId, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    switch (avatarId) {
      case 'fox':
        _drawFox(canvas, cx, cy, r);
        break;
      case 'cat':
        _drawCat(canvas, cx, cy, r);
        break;
      case 'dog':
        _drawDog(canvas, cx, cy, r);
        break;
      case 'panda':
        _drawPanda(canvas, cx, cy, r);
        break;
      case 'human_01':
        _drawHuman(
          canvas,
          cx,
          cy,
          r,
          hairColor: const Color(0xFF3D2314),
          capColor: const Color(0xFF4A7298),
          gender: 1,
        );
        break;
      case 'human_02':
        _drawHuman(
          canvas,
          cx,
          cy,
          r,
          hairColor: const Color(0xFF6A3B18),
          capColor: const Color(0xFF7C6DAF),
          gender: 2,
        );
        break;
      case 'human_03':
        _drawHuman(
          canvas,
          cx,
          cy,
          r,
          hairColor: const Color(0xFF212121),
          capColor: const Color(0xFF3B6E52),
          gender: 3,
        );
        break;
      case 'human_04':
        _drawHuman(
          canvas,
          cx,
          cy,
          r,
          hairColor: const Color(0xFF9E4B22),
          capColor: const Color(0xFFC8657B),
          gender: 4,
        );
        break;
      default:
        _drawFox(canvas, cx, cy, r);
    }
  }

  void _drawFox(Canvas canvas, double cx, double cy, double r) {
    final orange = isDark ? const Color(0xFFD46D32) : const Color(0xFFE65100);
    final white = isDark ? const Color(0xFFDCD2C5) : Colors.white;
    final dark = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D201A);

    // Kulaklar
    final earPath1 = Path()
      ..moveTo(cx - r * 0.7, cy - r * 0.1)
      ..lineTo(cx - r * 0.65, cy - r * 0.8)
      ..lineTo(cx - r * 0.15, cy - r * 0.45)
      ..close();
    canvas.drawPath(earPath1, Paint()..color = orange);
    canvas.drawPath(
      Path()
        ..moveTo(cx - r * 0.62, cy - r * 0.15)
        ..lineTo(cx - r * 0.58, cy - r * 0.68)
        ..lineTo(cx - r * 0.22, cy - r * 0.42)
        ..close(),
      Paint()..color = dark,
    );

    final earPath2 = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.1)
      ..lineTo(cx + r * 0.65, cy - r * 0.8)
      ..lineTo(cx + r * 0.15, cy - r * 0.45)
      ..close();
    canvas.drawPath(earPath2, Paint()..color = orange);
    canvas.drawPath(
      Path()
        ..moveTo(cx + r * 0.62, cy - r * 0.15)
        ..lineTo(cx + r * 0.58, cy - r * 0.68)
        ..lineTo(cx + r * 0.22, cy - r * 0.42)
        ..close(),
      Paint()..color = dark,
    );

    // Kafa
    final headPath = Path()
      ..moveTo(cx, cy + r * 0.6)
      ..quadraticBezierTo(
        cx - r * 0.75,
        cy + r * 0.1,
        cx - r * 0.55,
        cy - r * 0.35,
      )
      ..quadraticBezierTo(cx, cy - r * 0.45, cx + r * 0.55, cy - r * 0.35)
      ..quadraticBezierTo(cx + r * 0.75, cy + r * 0.1, cx, cy + r * 0.6)
      ..close();
    canvas.drawPath(headPath, Paint()..color = orange);

    // Yanak beyazları
    final cheekPath = Path()
      ..moveTo(cx, cy + r * 0.6)
      ..lineTo(cx - r * 0.7, cy + r * 0.1)
      ..quadraticBezierTo(cx - r * 0.35, cy + r * 0.15, cx, cy + r * 0.2)
      ..quadraticBezierTo(
        cx + r * 0.35,
        cy + r * 0.15,
        cx + r * 0.7,
        cy + r * 0.1,
      )
      ..close();
    canvas.drawPath(cheekPath, Paint()..color = white);

    // Gözler
    final eyePaint = Paint()..color = dark;
    canvas.drawCircle(Offset(cx - r * 0.26, cy - r * 0.05), r * 0.09, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.26, cy - r * 0.05), r * 0.09, eyePaint);
    canvas.drawCircle(
      Offset(cx - r * 0.23, cy - r * 0.08),
      r * 0.03,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.29, cy - r * 0.08),
      r * 0.03,
      Paint()..color = Colors.white,
    );

    // Burun
    canvas.drawCircle(Offset(cx, cy + r * 0.42), r * 0.09, eyePaint);
  }

  void _drawCat(Canvas canvas, double cx, double cy, double r) {
    final gray = isDark ? const Color(0xFF8B8496) : const Color(0xFF6C5B7B);
    final pink = const Color(0xFFFFAAA6);
    final dark = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2E2633);

    // Kulaklar
    final p1 = Path()
      ..moveTo(cx - r * 0.65, cy - r * 0.1)
      ..lineTo(cx - r * 0.6, cy - r * 0.75)
      ..lineTo(cx - r * 0.15, cy - r * 0.4)
      ..close();
    canvas.drawPath(p1, Paint()..color = gray);
    canvas.drawPath(
      Path()
        ..moveTo(cx - r * 0.58, cy - r * 0.15)
        ..lineTo(cx - r * 0.54, cy - r * 0.62)
        ..lineTo(cx - r * 0.22, cy - r * 0.38)
        ..close(),
      Paint()..color = pink,
    );

    final p2 = Path()
      ..moveTo(cx + r * 0.65, cy - r * 0.1)
      ..lineTo(cx + r * 0.6, cy - r * 0.75)
      ..lineTo(cx + r * 0.15, cy - r * 0.4)
      ..close();
    canvas.drawPath(p2, Paint()..color = gray);
    canvas.drawPath(
      Path()
        ..moveTo(cx + r * 0.58, cy - r * 0.15)
        ..lineTo(cx + r * 0.54, cy - r * 0.62)
        ..lineTo(cx + r * 0.22, cy - r * 0.38)
        ..close(),
      Paint()..color = pink,
    );

    // Yüz
    canvas.drawCircle(
      Offset(cx, cy + r * 0.05),
      r * 0.56,
      Paint()..color = gray,
    );

    // Gözler
    final eyePaint = Paint()..color = const Color(0xFF80D8FF);
    canvas.drawCircle(Offset(cx - r * 0.24, cy - r * 0.05), r * 0.1, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.24, cy - r * 0.05), r * 0.1, eyePaint);
    canvas.drawCircle(
      Offset(cx - r * 0.24, cy - r * 0.05),
      r * 0.06,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.24, cy - r * 0.05),
      r * 0.06,
      Paint()..color = dark,
    );

    // Burun
    final nosePath = Path()
      ..moveTo(cx - r * 0.07, cy + r * 0.12)
      ..lineTo(cx + r * 0.07, cy + r * 0.12)
      ..lineTo(cx, cy + r * 0.2)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = pink);

    // Bıyıklar
    final linePaint = Paint()
      ..color = dark
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - r * 0.15, cy + r * 0.2),
      Offset(cx - r * 0.55, cy + r * 0.16),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx - r * 0.15, cy + r * 0.26),
      Offset(cx - r * 0.52, cy + r * 0.3),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.15, cy + r * 0.2),
      Offset(cx + r * 0.55, cy + r * 0.16),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.15, cy + r * 0.26),
      Offset(cx + r * 0.52, cy + r * 0.3),
      linePaint,
    );
  }

  void _drawDog(Canvas canvas, double cx, double cy, double r) {
    final brown = isDark ? const Color(0xFF9E784D) : const Color(0xFFC79A63);
    final darkBrown = isDark
        ? const Color(0xFF5A4126)
        : const Color(0xFF7A542E);
    final dark = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF261E14);

    // Düşük kulaklar
    final ear1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx - r * 0.52, cy - r * 0.05),
        width: r * 0.34,
        height: r * 0.65,
      ),
      Radius.circular(r * 0.18),
    );
    canvas.drawRRect(ear1, Paint()..color = darkBrown);

    final ear2 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx + r * 0.52, cy - r * 0.05),
        width: r * 0.34,
        height: r * 0.65,
      ),
      Radius.circular(r * 0.18),
    );
    canvas.drawRRect(ear2, Paint()..color = darkBrown);

    // Kafa
    canvas.drawCircle(Offset(cx, cy), r * 0.54, Paint()..color = brown);

    // Gözler
    canvas.drawCircle(
      Offset(cx - r * 0.22, cy - r * 0.1),
      r * 0.08,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.22, cy - r * 0.1),
      r * 0.08,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.2, cy - r * 0.12),
      r * 0.025,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.24, cy - r * 0.12),
      r * 0.025,
      Paint()..color = Colors.white,
    );

    // Ağız / burun alanı (beyazımsı leke)
    final muzzle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.22),
        width: r * 0.44,
        height: r * 0.34,
      ),
      Radius.circular(r * 0.15),
    );
    canvas.drawRRect(
      muzzle,
      Paint()
        ..color = isDark ? const Color(0xFFDED0BC) : const Color(0xFFF7EFE3),
    );

    // Burun
    canvas.drawCircle(
      Offset(cx, cy + r * 0.16),
      r * 0.085,
      Paint()..color = dark,
    );
  }

  void _drawPanda(Canvas canvas, double cx, double cy, double r) {
    final white = isDark ? const Color(0xFFE0E5E2) : Colors.white;
    final black = isDark ? const Color(0xFF1E2822) : const Color(0xFF2A3630);

    // Kulaklar
    canvas.drawCircle(
      Offset(cx - r * 0.46, cy - r * 0.45),
      r * 0.22,
      Paint()..color = black,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.46, cy - r * 0.45),
      r * 0.22,
      Paint()..color = black,
    );

    // Yüz
    canvas.drawCircle(
      Offset(cx, cy + r * 0.05),
      r * 0.58,
      Paint()..color = white,
    );

    // Göz çevresi siyah yamalar
    canvas.save();
    canvas.translate(cx - r * 0.25, cy - r * 0.04);
    canvas.rotate(-0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.32, height: r * 0.24),
      Paint()..color = black,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(cx + r * 0.25, cy - r * 0.04);
    canvas.rotate(0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.32, height: r * 0.24),
      Paint()..color = black,
    );
    canvas.restore();

    // Göz bebekleri
    canvas.drawCircle(
      Offset(cx - r * 0.23, cy - r * 0.04),
      r * 0.055,
      Paint()..color = white,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.23, cy - r * 0.04),
      r * 0.055,
      Paint()..color = white,
    );

    // Burun
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.22),
        width: r * 0.18,
        height: r * 0.12,
      ),
      Paint()..color = black,
    );
  }

  void _drawHuman(
    Canvas canvas,
    double cx,
    double cy,
    double r, {
    required Color hairColor,
    required Color capColor,
    required int gender,
  }) {
    final skin = isDark ? const Color(0xFFDCA988) : const Color(0xFFFFCCAA);
    final dark = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2B2B2B);

    // Saç arkası
    canvas.drawCircle(
      Offset(cx, cy - r * 0.1),
      r * 0.56,
      Paint()..color = hairColor,
    );

    // Yüz
    canvas.drawCircle(
      Offset(cx, cy + r * 0.05),
      r * 0.46,
      Paint()..color = skin,
    );

    // Saç önü / Başlık
    final cap = Path()
      ..moveTo(cx - r * 0.48, cy - r * 0.05)
      ..quadraticBezierTo(cx, cy - r * 0.7, cx + r * 0.48, cy - r * 0.05)
      ..quadraticBezierTo(cx, cy - r * 0.3, cx - r * 0.48, cy - r * 0.05)
      ..close();
    canvas.drawPath(cap, Paint()..color = capColor);

    // Gözler
    canvas.drawCircle(
      Offset(cx - r * 0.18, cy + r * 0.05),
      r * 0.065,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.18, cy + r * 0.05),
      r * 0.065,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.16, cy + r * 0.03),
      r * 0.02,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.2, cy + r * 0.03),
      r * 0.02,
      Paint()..color = Colors.white,
    );

    // Gülümseme
    final smile = Path()
      ..moveTo(cx - r * 0.12, cy + r * 0.26)
      ..quadraticBezierTo(cx, cy + r * 0.36, cx + r * 0.12, cy + r * 0.26);
    canvas.drawPath(
      smile,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // Yanak allığı
    canvas.drawCircle(
      Offset(cx - r * 0.28, cy + r * 0.18),
      r * 0.07,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      Offset(cx + r * 0.28, cy + r * 0.18),
      r * 0.07,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.avatarId != avatarId || oldDelegate.isDark != isDark;
  }
}
