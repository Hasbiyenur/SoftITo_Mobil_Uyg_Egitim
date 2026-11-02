import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aliskanlik_takibi/core/widgets/primary_button.dart';

void main() {
  group('PrimaryButton ve Seçilenleri Kaldır Buton Testleri', () {
    testWidgets(
      'PrimaryButton dar alanda metni tek satırda tutar ve FittedBox ile ölçekler',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 140, // Dar buton genişliği
                child: PrimaryButton(
                  text: 'Seçilenleri Kaldır (5)',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final textFinder = find.text('Seçilenleri Kaldır (5)');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.maxLines, equals(1));
        expect(textWidget.softWrap, isFalse);

        // FittedBox ile sarmalandığını doğrula
        final fittedBoxFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(FittedBox),
        );
        expect(fittedBoxFinder, findsOneWidget);
        final fittedBox = tester.widget<FittedBox>(fittedBoxFinder);
        expect(fittedBox.fit, equals(BoxFit.scaleDown));
      },
    );

    testWidgets(
      'İptal ve Seçilenleri Kaldır eylem satırı 360px genişlikte taşma yapmaz',
      (tester) async {
        // 360 x 640 ekran boyutu simülasyonu
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: 'İptal',
                        isOutlined: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        text: 'Seçilenleri Kaldır (99)',
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('İptal'), findsOneWidget);
        expect(find.text('Seçilenleri Kaldır (99)'), findsOneWidget);

        final removeText = tester.widget<Text>(
          find.text('Seçilenleri Kaldır (99)'),
        );
        expect(removeText.maxLines, equals(1));
        expect(removeText.softWrap, isFalse);
      },
    );
  });
}
