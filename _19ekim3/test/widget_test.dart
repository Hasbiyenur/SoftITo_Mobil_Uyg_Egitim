import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/main.dart';

void main() {
  testWidgets('Uygulama açılış duman testi', (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());
    await tester.pump();

    expect(find.text('Su Takibi'), findsWidgets);
    expect(find.text('Günlük Hedef'), findsOneWidget);
  });
}
