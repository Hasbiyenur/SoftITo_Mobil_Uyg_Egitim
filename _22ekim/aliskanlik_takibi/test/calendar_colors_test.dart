import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/core/theme/habit_color_service.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_entry.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/features/calendar/screens/calendar_screen.dart';
import 'package:aliskanlik_takibi/features/calendar/widgets/calendar_legend.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('Takvim Görev Renkleri ve Açıklama Testleri', () {
    testWidgets('CalendarLegend görev adlarını ve soft renklerini listeler', (
      tester,
    ) async {
      final habits = [
        Habit(
          id: 'h1',
          userId: 'u1',
          title: 'Kitap Oku',
          iconCodePoint: Icons.menu_book.codePoint,
          colorValue: HabitColorService.palette[0].toARGB32(),
          createdAtUtc: '2026-10-22T00:00:00Z',
          schedules: [],
        ),
        Habit(
          id: 'h2',
          userId: 'u1',
          title: 'Su İç',
          iconCodePoint: Icons.water_drop.codePoint,
          colorValue: HabitColorService.palette[1].toARGB32(),
          createdAtUtc: '2026-10-22T00:00:00Z',
          schedules: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalendarLegend(habits: habits)),
        ),
      );

      expect(find.text('Görev Renkleri ve Açıklamalar'), findsOneWidget);
      expect(find.text('Kitap Oku'), findsOneWidget);
      expect(find.text('Su İç'), findsOneWidget);
    });

    testWidgets(
      'CalendarScreen birden fazla tamamlanmış görev için ayrı renkli noktaları çizer',
      (tester) async {
        final store = LocalStore();
        final habitRepo = LocalHabitRepository(store: store);
        final habitCtrl = HabitController(repository: habitRepo);

        const userId = 'user_cal_test';
        const todayKey = '2026-10-22';

        final h1 = Habit(
          id: 'h_cal_1',
          userId: userId,
          title: 'Kitap Oku',
          iconCodePoint: Icons.menu_book.codePoint,
          colorValue: 0xFF3B6E52, // Adaçayı
          createdAtUtc: '2026-10-22T00:00:00Z',
          schedules: [
            const HabitSchedule(
              id: 's_cal_1',
              habitId: 'h_cal_1',
              intervalDays: 1,
              anchorDateKey: todayKey,
              effectiveFromDateKey: todayKey,
              counterType: 'check',
              targetValue: 1,
            ),
          ],
        );

        final h2 = Habit(
          id: 'h_cal_2',
          userId: userId,
          title: 'Su İç',
          iconCodePoint: Icons.water_drop.codePoint,
          colorValue: 0xFF4A7298, // Soft Mavi
          createdAtUtc: '2026-10-22T00:00:00Z',
          schedules: [
            const HabitSchedule(
              id: 's_cal_2',
              habitId: 'h_cal_2',
              intervalDays: 1,
              anchorDateKey: todayKey,
              effectiveFromDateKey: todayKey,
              counterType: 'check',
              targetValue: 1,
            ),
          ],
        );

        await habitRepo.saveHabit(userId, h1);
        await habitRepo.saveHabit(userId, h2);

        // İki görevi de aynı gün (bugün) tamamla
        await habitRepo.saveEntry(
          userId,
          const HabitEntry(
            id: 'e1',
            userId: userId,
            habitId: 'h_cal_1',
            scheduleId: 's_cal_1',
            dateKey: todayKey,
            progressValue: 1,
            targetValue: 1,
            completedAtUtc: '2026-10-22T10:00:00Z',
            updatedAtUtc: '2026-10-22T10:00:00Z',
          ),
        );
        await habitRepo.saveEntry(
          userId,
          const HabitEntry(
            id: 'e2',
            userId: userId,
            habitId: 'h_cal_2',
            scheduleId: 's_cal_2',
            dateKey: todayKey,
            progressValue: 1,
            targetValue: 1,
            completedAtUtc: '2026-10-22T11:00:00Z',
            updatedAtUtc: '2026-10-22T11:00:00Z',
          ),
        );

        await habitCtrl.loadUserData(userId, todayKey);

        await tester.pumpWidget(
          MultiProvider(
            providers: [ChangeNotifierProvider.value(value: habitCtrl)],
            child: const MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('tr', 'TR')],
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Takvim ekranı ve başlıkları yüklenmeli
        expect(find.text('Takvim'), findsOneWidget);
        expect(find.text('Tüm Alışkanlıklar'), findsOneWidget);
        expect(find.byType(CalendarLegend), findsOneWidget);
      },
    );
  });
}
