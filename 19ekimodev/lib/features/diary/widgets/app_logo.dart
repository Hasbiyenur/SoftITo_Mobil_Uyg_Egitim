import 'package:flutter/material.dart';

/// Günlüğüm uygulama logosu ve başlık bileşeni.
/// Hem görsel asset logo hem de `Icons.auto_stories_rounded` vektör simgesini destekler.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showImage;

  const AppLogo({
    super.key,
    this.size = 28,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: Image.asset(
              'assets/images/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.auto_stories_rounded,
                  size: size,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          )
        else
          Icon(
            Icons.auto_stories_rounded,
            size: size,
            color: Theme.of(context).colorScheme.primary,
          ),
        const SizedBox(width: 10),
        Text(
          'Günlüğüm',
          style: TextStyle(
            fontSize: size * 0.72,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
