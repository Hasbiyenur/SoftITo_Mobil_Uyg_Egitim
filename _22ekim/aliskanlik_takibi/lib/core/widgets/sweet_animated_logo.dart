import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Tatlı, canlı ve organik animasyonlu uygulama logosu.
///
/// Küçük adımlarla büyüyen bir filiz/yaprak karakterini simgeler.
/// Hafif nefes alma (breathing float), rüzgar salınımı (sway), ara sıra
/// sevimli göz kırpma (blink) ve parıldayan çiy damlası (sparkle) efektleri içerir.
/// Dokunulduğunda sevimli bir zıplama ve minik parıltı yayılımı gerçekleştirir.
class SweetAnimatedLogo extends StatefulWidget {
  final double size;
  final bool interactive;
  final VoidCallback? onTap;
  final bool autoAnimate;
  final String? tooltip;

  const SweetAnimatedLogo({
    super.key,
    this.size = 44,
    this.interactive = true,
    this.onTap,
    this.autoAnimate = true,
    this.tooltip,
  });

  @override
  State<SweetAnimatedLogo> createState() => _SweetAnimatedLogoState();
}

class _SweetAnimatedLogoState extends State<SweetAnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _blinkController;
  late final AnimationController _sparkleController;
  late final AnimationController _tapController;

  late final Animation<double> _floatAnim;
  late final Animation<double> _swayAnim;
  late final Animation<double> _blinkAnim;
  late final Animation<double> _sparkleAnim;
  late final Animation<double> _tapSquishAnim;
  late final Animation<double> _tapHopAnim;

  bool get _isTestEnv {
    if (kIsWeb) return false;
    return Platform.environment.containsKey('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().contains(
          'TestWidgetsFlutterBinding',
        );
  }

  @override
  void initState() {
    super.initState();

    // 1. Nazik nefes alma ve hafif salınım (2.6 sn döngü)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _floatAnim = Tween<double>(begin: -1.8, end: 1.8).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
    _swayAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 2. Sevimli göz kırpma (3.6 sn döngü, sadece son %10'luk dilimde kapanıp açılır)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 88),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 6,
      ),
    ]).animate(_blinkController);

    // 3. Çiy damlası ışıltısı (2.0 sn döngü)
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _sparkleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // 4. Dokunma / Zıplama animasyonu (yaylı elastik efekt)
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _tapSquishAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.88,
          end: 1.14,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.14,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_tapController);

    _tapHopAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 2.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2.0,
          end: -7.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -7.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(_tapController);

    // Test ortamında tester.pumpAndSettle'ı engellememek için döngü başlatılmaz
    if (widget.autoAnimate && !_isTestEnv) {
      _breathingController.repeat(reverse: true);
      _blinkController.repeat();
      _sparkleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _sparkleController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.interactive) return;

    if (!_tapController.isAnimating) {
      _tapController.forward(from: 0.0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget logo = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingController,
          _blinkController,
          _sparkleController,
          _tapController,
        ]),
        builder: (context, _) {
          final floatOffset = reduceMotion ? 0.0 : _floatAnim.value;
          final swayRotation = reduceMotion ? 0.0 : _swayAnim.value;
          final blinkProgress = reduceMotion ? 0.0 : _blinkAnim.value;
          final sparkleValue = reduceMotion ? 0.8 : _sparkleAnim.value;
          final squish = reduceMotion ? 1.0 : _tapSquishAnim.value;
          final hop = reduceMotion ? 0.0 : _tapHopAnim.value;
          final tapProgress = _tapController.value;

          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SweetLogoPainter(
              isDark: isDark,
              floatY: floatOffset + hop,
              swayAngle: swayRotation,
              blinkFactor: blinkProgress,
              sparkleOpacity: sparkleValue,
              squishFactor: squish,
              tapProgress: tapProgress,
            ),
          );
        },
      ),
    );

    if (widget.interactive) {
      logo = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: logo,
      );
    }

    if (widget.tooltip != null) {
      logo = Tooltip(message: widget.tooltip!, child: logo);
    }

    return Semantics(
      label: 'Alışkanlık Takibi Canlı Logo',
      hint: widget.interactive ? 'Tatlı animasyon için dokun' : null,
      button: widget.interactive,
      child: logo,
    );
  }
}

class _SweetLogoPainter extends CustomPainter {
  final bool isDark;
  final double floatY;
  final double swayAngle;
  final double blinkFactor; // 0.0: tam açık, 1.0: tam kapalı göz
  final double sparkleOpacity;
  final double squishFactor;
  final double tapProgress;

  _SweetLogoPainter({
    required this.isDark,
    required this.floatY,
    required this.swayAngle,
    required this.blinkFactor,
    required this.sparkleOpacity,
    required this.squishFactor,
    required this.tapProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Zemin Kartı (Modern Squircle / Yuvarlatılmış Kare Rozet)
    final badgeRadius = Radius.circular(w * 0.28);
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      badgeRadius,
    );

    // Koyu / Açık tema gölgesi
    final shadowPaint = Paint()
      ..color = (isDark ? const Color(0xFFAEC9A5) : const Color(0xFF3B6E52))
          .withValues(alpha: isDark ? 0.16 : 0.14)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.14);
    canvas.drawRRect(badgeRect.shift(Offset(0, w * 0.06)), shadowPaint);

    // Rozet Arka Plan Gradyanı
    final badgeGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF26392F), Color(0xFF1B2921)]
          : const [Color(0xFFEBF5ED), Color(0xFFD6EAD9)],
    );
    final badgePaint = Paint()
      ..shader = badgeGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRect, badgePaint);

    // Rozet İnce Çerçevesi
    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF3B5646) : const Color(0xFFBFDEC5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.028);
    canvas.drawRRect(badgeRect, borderPaint);

    // 2. Karakter Gövdesi ve Yapraklar (Hareket ve Salınım Matrisi)
    canvas.save();

    // Dönme ve zıplama merkezi: rozetin alt-orta kısmı
    final pivotX = cx;
    final pivotY = cy + h * 0.26;

    canvas.translate(pivotX, pivotY + floatY);
    // Squish (Ezilme/Esnek Yaylanma)
    final scaleY = squishFactor;
    final scaleX = 1.0 / math.sqrt(squishFactor);
    canvas.scale(scaleX, scaleY);
    // Hafif rüzgar salınımı
    canvas.rotate(swayAngle);
    canvas.translate(-pivotX, -pivotY);

    // A. Sevimli Kavisli Filiz Sapı (Stem)
    final stemPaint = Paint()
      ..color = isDark ? const Color(0xFF75BE88) : const Color(0xFF3B7E4C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.065)
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(cx - w * 0.04, cy + h * 0.26)
      ..quadraticBezierTo(
        cx - w * 0.06,
        cy + h * 0.08,
        cx + w * 0.02,
        cy - h * 0.04,
      );
    canvas.drawPath(stemPath, stemPaint);

    // B. Sol Minik Yavru Yaprak (Baby Leaf)
    final babyLeafPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: isDark
                ? const [Color(0xFF67B57C), Color(0xFF86D59A)]
                : const [Color(0xFF5BA36C), Color(0xFF7CC78C)],
          ).createShader(
            Rect.fromLTWH(cx - w * 0.32, cy - h * 0.12, w * 0.4, h * 0.4),
          )
      ..style = PaintingStyle.fill;

    final babyLeafPath = Path()
      ..moveTo(cx - w * 0.03, cy + h * 0.10)
      ..cubicTo(
        cx - w * 0.20,
        cy + h * 0.14,
        cx - w * 0.30,
        cy - h * 0.02,
        cx - w * 0.22,
        cy - h * 0.10,
      )
      ..cubicTo(
        cx - w * 0.12,
        cy - h * 0.15,
        cx - w * 0.02,
        cy - h * 0.02,
        cx - w * 0.03,
        cy + h * 0.10,
      );
    canvas.drawPath(babyLeafPath, babyLeafPaint);

    // C. Ana Sağ Yaprak (Primary Living Leaf - Dolgun, Neşeli)
    final mainLeafPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: isDark
                ? const [Color(0xFF76C48B), Color(0xFFA5E6B7)]
                : const [Color(0xFF458C56), Color(0xFF6BBB7D)],
          ).createShader(
            Rect.fromLTWH(cx - w * 0.1, cy - h * 0.36, w * 0.48, h * 0.55),
          )
      ..style = PaintingStyle.fill;

    final mainLeafPath = Path()
      ..moveTo(cx + w * 0.01, cy + h * 0.04)
      ..cubicTo(
        cx + w * 0.26,
        cy + h * 0.06,
        cx + w * 0.32,
        cy - h * 0.18,
        cx + w * 0.21,
        cy - h * 0.30,
      )
      ..cubicTo(
        cx + w * 0.08,
        cy - h * 0.36,
        cx - w * 0.08,
        cy - h * 0.16,
        cx + w * 0.01,
        cy + h * 0.04,
      );
    canvas.drawPath(mainLeafPath, mainLeafPaint);

    // Yaprak İç Damarı (Delicate soft vein)
    final veinPaint = Paint()
      ..color = (isDark ? const Color(0xFFD4F7DF) : const Color(0xFFB4E7C2))
          .withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, w * 0.024)
      ..strokeCap = StrokeCap.round;

    final veinPath = Path()
      ..moveTo(cx + w * 0.02, cy + h * 0.02)
      ..quadraticBezierTo(
        cx + w * 0.08,
        cy - h * 0.12,
        cx + w * 0.18,
        cy - h * 0.25,
      );
    canvas.drawPath(veinPath, veinPaint);

    // D. Tatlı Yüz İfadesi (The Sweet Expressive Face)
    // Yüzün merkez konumu
    final faceCx = cx + w * 0.07;
    final faceCy = cy - h * 0.08;

    // 1. Pembe Yanaklar (Sweet Rosy Cheeks)
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8B94).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final blushR = w * 0.044;
    canvas.drawCircle(
      Offset(faceCx - w * 0.09, faceCy + h * 0.04),
      blushR,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(faceCx + w * 0.09, faceCy + h * 0.04),
      blushR,
      blushPaint,
    );

    // 2. Gözler (Canlı & Sevimli Parlayan Gözler veya Kırpma Çizgisi)
    final eyeColor = isDark ? const Color(0xFF142419) : const Color(0xFF1B3322);
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    final leftEyeCenter = Offset(faceCx - w * 0.065, faceCy - h * 0.01);
    final rightEyeCenter = Offset(faceCx + w * 0.065, faceCy - h * 0.01);
    final eyeRadius = w * 0.038;

    if (blinkFactor > 0.4) {
      // Göz kırpıldığında tatlı neşeli yaylar (^ ^)
      final eyeArcPaint = Paint()
        ..color = eyeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, w * 0.032)
        ..strokeCap = StrokeCap.round;

      final leftArc = Path()
        ..moveTo(
          leftEyeCenter.dx - eyeRadius,
          leftEyeCenter.dy + eyeRadius * 0.4,
        )
        ..quadraticBezierTo(
          leftEyeCenter.dx,
          leftEyeCenter.dy - eyeRadius * 0.8,
          leftEyeCenter.dx + eyeRadius,
          leftEyeCenter.dy + eyeRadius * 0.4,
        );
      final rightArc = Path()
        ..moveTo(
          rightEyeCenter.dx - eyeRadius,
          rightEyeCenter.dy + eyeRadius * 0.4,
        )
        ..quadraticBezierTo(
          rightEyeCenter.dx,
          rightEyeCenter.dy - eyeRadius * 0.8,
          rightEyeCenter.dx + eyeRadius,
          rightEyeCenter.dy + eyeRadius * 0.4,
        );
      canvas.drawPath(leftArc, eyeArcPaint);
      canvas.drawPath(rightArc, eyeArcPaint);
    } else {
      // Açık gözler + sevimli beyaz ışıltı benekleri
      canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);

      // Beyaz minik parlama noktaları (Göz bebeği ışıltısı)
      final shinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final shineR = eyeRadius * 0.38;
      canvas.drawCircle(
        Offset(
          leftEyeCenter.dx + eyeRadius * 0.3,
          leftEyeCenter.dy - eyeRadius * 0.3,
        ),
        shineR,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(
          rightEyeCenter.dx + eyeRadius * 0.3,
          rightEyeCenter.dy - eyeRadius * 0.3,
        ),
        shineR,
        shinePaint,
      );
    }

    // 3. Minik Tatlı Gülümseme (Cute Little Smile)
    final smilePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.1, w * 0.028)
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(faceCx - w * 0.032, faceCy + h * 0.035)
      ..quadraticBezierTo(
        faceCx,
        faceCy + h * 0.075,
        faceCx + w * 0.032,
        faceCy + h * 0.035,
      );
    canvas.drawPath(smilePath, smilePaint);

    // E. Yaprak Ucunda Parıldayan Çiy Damlası / Yıldız (Morning Dewdrop Sparkle)
    final sparkleCx = cx + w * 0.22;
    final sparkleCy = cy - h * 0.31;
    _drawSparkleStar(
      canvas,
      Offset(sparkleCx, sparkleCy),
      w * 0.075 * (0.6 + sparkleOpacity * 0.4),
      sparkleOpacity,
      isDark ? const Color(0xFFF3FFD8) : const Color(0xFFFFF7C2),
    );

    // F. Dokunulduğunda Saçılan Minik Neşeli Parıltılar (Tap Particles)
    if (tapProgress > 0.0 && tapProgress < 1.0) {
      final p1 = 1.0 - tapProgress;
      final alpha = (p1 * 0.9).clamp(0.0, 1.0);

      // Altın Yıldız 1 (Sağ Üst)
      final offset1 = Offset(
        cx + w * (0.24 + tapProgress * 0.16),
        cy - h * (0.24 + tapProgress * 0.20),
      );
      _drawSparkleStar(
        canvas,
        offset1,
        w * 0.06 * p1,
        alpha,
        const Color(0xFFFFD54F),
      );

      // Pembe Kalp / Minik Işık 2 (Sol Üst)
      final offset2 = Offset(
        cx - w * (0.16 + tapProgress * 0.18),
        cy - h * (0.14 + tapProgress * 0.22),
      );
      _drawSparkleStar(
        canvas,
        offset2,
        w * 0.05 * p1,
        alpha,
        const Color(0xFFFF8DA1),
      );

      // Nane Yeşili Minik Yıldız 3 (Orta Üst)
      final offset3 = Offset(
        cx + w * (0.02 + tapProgress * 0.08),
        cy - h * (0.34 + tapProgress * 0.16),
      );
      _drawSparkleStar(
        canvas,
        offset3,
        w * 0.055 * p1,
        alpha,
        const Color(0xFF80E27E),
      );
    }

    canvas.restore();
  }

  void _drawSparkleStar(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
    Color color,
  ) {
    if (radius <= 0.5) return;

    final starPaint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 4;
    final innerR = radius * 0.32;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerR;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);

    // Merkez ışıltı halkası
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: (opacity * 0.7).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.25, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SweetLogoPainter oldDelegate) {
    return oldDelegate.floatY != floatY ||
        oldDelegate.swayAngle != swayAngle ||
        oldDelegate.blinkFactor != blinkFactor ||
        oldDelegate.sparkleOpacity != sparkleOpacity ||
        oldDelegate.squishFactor != squishFactor ||
        oldDelegate.tapProgress != tapProgress ||
        oldDelegate.isDark != isDark;
  }
}
