import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aliskanlik_takibi/core/widgets/app_logo.dart';
import 'package:aliskanlik_takibi/core/widgets/sweet_animated_logo.dart';

void main() {
  group('SweetAnimatedLogo ve Canlı Logo Testleri', () {
    testWidgets('SweetAnimatedLogo belirtilen boyutta hatasız render edilir', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SweetAnimatedLogo(size: 44, tooltip: 'Alışkanlık Takibi'),
            ),
          ),
        ),
      );

      expect(find.byType(SweetAnimatedLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final logoBox = tester.renderObject<RenderBox>(
        find.byType(SweetAnimatedLogo),
      );
      expect(logoBox.size.width, equals(44));
      expect(logoBox.size.height, equals(44));
    });

    testWidgets('SweetAnimatedLogo dokunulduğunda onTap tetiklenir', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SweetAnimatedLogo(
                size: 56,
                interactive: true,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SweetAnimatedLogo));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapped, isTrue);
    });

    testWidgets('AppLogo SweetAnimatedLogo içerir ve metinleri görüntüler', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppLogo(size: 64, showText: true, showSubtitle: true),
            ),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(SweetAnimatedLogo), findsOneWidget);
      expect(find.text('Alışkanlık Takibi'), findsOneWidget);
      expect(find.text('Küçük adımlar, kalıcı alışkanlıklar.'), findsOneWidget);
    });
  });
}
