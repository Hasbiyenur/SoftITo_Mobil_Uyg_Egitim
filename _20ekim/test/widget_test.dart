import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:girisimcilik/main.dart';

void main() {
  testWidgets('Girisimcilik ana ekran ve gezinme duman testi',
      (WidgetTester tester) async {
    // Uygulama ağacını yükle
    await tester.pumpWidget(const GirisimcilikApp());
    await tester.pumpAndSettle();

    // Ana ekran başlığı ve kategorileri kontrol et
    expect(find.text('Girişimcilik'), findsWidgets);
    expect(find.text('Girişimcilik Rehberi'), findsOneWidget);
    expect(find.text('Mentorlar'), findsOneWidget);
    expect(find.text('Hukuki Destek'), findsOneWidget);
    expect(find.text('Destek, Teşvik ve Yatırımcılar'), findsOneWidget);

    // Karanlık moda geçişi test et
    final darkModeButton = find.byTooltip('Karanlık Moda Geç');
    expect(darkModeButton, findsOneWidget);
    await tester.tap(darkModeButton);
    await tester.pumpAndSettle();

    // Karanlık modda butonun Aydınlık Moda Geç olduğunu doğrula
    final lightModeButton = find.byTooltip('Aydınlık Moda Geç');
    expect(lightModeButton, findsOneWidget);

    // Tekrar aydınlık moda dön
    await tester.tap(lightModeButton);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Karanlık Moda Geç'), findsOneWidget);

    // Destek, Teşvik ve Yatırımcılar kartına kaydır ve dokun
    final supportsFinder = find.text('Destek, Teşvik ve Yatırımcılar');
    await tester.ensureVisible(supportsFinder);
    await tester.pumpAndSettle();
    await tester.tap(supportsFinder);
    await tester.pumpAndSettle();

    // İki alt sekmenin olduğunu doğrula
    expect(find.text('Devlet Destekleri'), findsOneWidget);
    expect(find.text('Yatırımcılar'), findsOneWidget);

    // Yatırımcılar sekmesine geç
    await tester.tap(find.text('Yatırımcılar'));
    await tester.pumpAndSettle();

    // Yatırımcı kavramları başlığını doğrula
    expect(find.text('Melek Yatırımcı (Angel Investor)'), findsOneWidget);

    // Yatırımcılar sekmesini aşağı kaydır ve demo yatırımcı profilini doğrula
    await tester.drag(
      find.byKey(const Key('investors_tab_list')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kerem Aras (Demo Melek Yatırımcı)'), findsOneWidget);

    // Geri dön
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Ana ekrana dönüldüğünü doğrula
    expect(find.text('Keşfetmeye Başlayın'), findsOneWidget);
  });
}
