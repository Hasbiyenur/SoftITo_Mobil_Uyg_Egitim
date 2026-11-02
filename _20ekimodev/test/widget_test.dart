import 'package:flutter_test/flutter_test.dart';
import 'package:arac_kiralama/app.dart';
import 'package:arac_kiralama/state/app_state.dart';

void main() {
  testWidgets('Rento app splash and home smoke test', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(CarRentalApp(appState: appState));

    // Girişte logo ve Rento metni görünür
    expect(find.text('Ren'), findsWidgets);
    expect(find.text('to'), findsWidgets);

    // Splash süresini ilerlet (2000ms + 400ms transition)
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Ana Sayfa başlığı ve sekmelerinin yüklendiğini kontrol et
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Filtreleme'), findsOneWidget);
    expect(find.text('Araç Ekle'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
