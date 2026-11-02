import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunlugum/app.dart';

void main() {
  testWidgets('Uygulama açılır, başlık ve sekmeler doğru yüklenir',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DiaryApp());

    // Başlık ve logo
    expect(find.text('Günlüğüm'), findsOneWidget);

    // Sekmeler
    expect(find.text('Günlük Yaz'), findsOneWidget);
    expect(find.text('Günlüklerim'), findsOneWidget);

    // Editör form parçaları
    expect(find.text('Kaydet'), findsOneWidget);
  });

  testWidgets('Günlük yazma, kaydetme ve listede görüntüleme akışı',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DiaryApp());

    // 1. Metin alanına günlük yaz
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(
        textFieldFinder, 'Bugün Flutter ile harika bir günlük yazdım!');
    await tester.pump();

    // 2. Kaydet butonuna tıkla
    final saveButtonFinder = find.widgetWithText(FilledButton, 'Kaydet');
    expect(saveButtonFinder, findsOneWidget);
    await tester.tap(saveButtonFinder);
    await tester.pump(); // SnackBar tetiklensin

    // 3. Başarı bildirimini doğrula
    expect(find.text('Günlük başarıyla kaydedildi.'), findsOneWidget);

    // 4. "Günlüklerim" sekmesine geç
    final listTabFinder = find.text('Günlüklerim');
    await tester.tap(listTabFinder);
    await tester.pumpAndSettle();

    // 5. Kaydedilen günlüğün listede olduğunu doğrula
    expect(find.text('Bugün Flutter ile harika bir günlük yazdım!'),
        findsOneWidget);
  });

  testWidgets('Tema değiştirme butonu çalışır ve arayüz güncellenir',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DiaryApp());

    // Tema değiştirme butonunu bul ve tıkla
    final themeButtonFinder = find.byTooltip('Koyu Temaya Geç');
    expect(themeButtonFinder, findsOneWidget);

    await tester.tap(themeButtonFinder);
    await tester.pumpAndSettle();

    // Şimdi açık temaya geçiş tooltip'i görünmeli
    expect(find.byTooltip('Açık Temaya Geç'), findsOneWidget);
  });
}
