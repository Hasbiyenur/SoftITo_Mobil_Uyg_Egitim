import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/main.dart';

void main() {
  testWidgets('Susadım app smoke test and water addition test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());
    await tester.pumpAndSettle();

    // Verify initial title and water target are displayed
    expect(find.text('SUSADIM'), findsOneWidget);
    expect(find.text('Hedef'), findsOneWidget);

    // Tap quick add water button (+200 ml)
    final quickBtn = find.text('200 ml');
    expect(quickBtn, findsOneWidget);
    await tester.tap(quickBtn);
    await tester.pumpAndSettle();

    // Verify consumed water amount updated
    expect(find.text('200'), findsOneWidget);

    // Switch to Workout tab
    final workoutTab = find.byIcon(Icons.fitness_center_outlined);
    expect(workoutTab, findsOneWidget);
    await tester.tap(workoutTab);
    await tester.pumpAndSettle();

    // Verify workout view is displayed
    expect(find.text('AKTİVİTE'), findsOneWidget);
    expect(find.text('Yeni Egzersiz Ekle'), findsOneWidget);

    // Switch to Sleep tab
    final sleepTab = find.byIcon(Icons.bedtime_outlined);
    expect(sleepTab, findsOneWidget);
    await tester.tap(sleepTab);
    await tester.pumpAndSettle();

    // Verify sleep view is displayed
    expect(find.text('UYKU ZAMANI'), findsOneWidget);
    expect(find.text('Uyku Kaydı Ekle'), findsOneWidget);
  });
}
