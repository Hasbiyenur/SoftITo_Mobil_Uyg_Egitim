import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/main.dart';

void main() {
  testWidgets('Susadım v1 duman ve tema geçiş testi', (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());
    expect(find.text('Susadım'), findsOneWidget);
    expect(find.text('Günlük Hidrasyon'), findsOneWidget);

    // Koyu moddan aydınlık moda geçiş butonu
    final lightModeBtn = find.byIcon(Icons.light_mode_rounded);
    expect(lightModeBtn, findsOneWidget);

    // Dokunarak aydınlık moda geç
    await tester.tap(lightModeBtn);
    await tester.pumpAndSettle();

    // Artık karanlık moda geçiş butonu (ay ikonu) görünmeli
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });
}
