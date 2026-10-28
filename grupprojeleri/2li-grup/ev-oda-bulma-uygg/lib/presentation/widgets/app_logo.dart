import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Roomio uygulamasının modern çatı ikonunu ve marka metnini içeren yeniden kullanılabilir logo bileşeni.
/// Giriş, kayıt ve splash ekranlarında farklı boyut ve renk seçenekleriyle kullanılır.
class AppLogo extends StatelessWidget {
  /// Logonun piksel cinsinden genişlik ve yükseklik boyutu
  final double size;

  /// Marka isminin (Roomio) ve alt açıklama metninin gösterilip gösterilmeyeceği
  final bool showText;

  /// Logo ikonu için özel renk geçersiz kılma (null ise temaya göre otomatik seçilir)
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        color ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradyanlı, gölgeli ve yuvarlatılmış çatı ikonu kutusu
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, AppColors.secondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.roofing_rounded,
            size: size * 0.6,
            color: Colors.white,
          ),
        ),
        // Marka metni ve slogan
        if (showText) ...[
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? AppColors.textDark : AppColors.textLightPrimary,
              ),
              children: [
                const TextSpan(text: 'Room'),
                TextSpan(
                  text: 'io',
                  style: TextStyle(color: primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ev & Oda Arkadaşı Bulma',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textDark.withAlpha(160)
                  : AppColors.textLightSecondary.withAlpha(160),
            ),
          ),
        ],
      ],
    );
  }
}
