import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/data/demo/demo_seed.dart';
import 'package:aliskanlik_takibi/data/repositories/local_auth_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_pomodoro_repository.dart';
import 'package:aliskanlik_takibi/data/motivation/motivation_repository.dart';
import 'package:aliskanlik_takibi/features/auth/auth_controller.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';
import 'package:aliskanlik_takibi/features/home/screens/home_screen.dart';
import 'package:aliskanlik_takibi/features/motivation/completion_feedback_controller.dart';
import 'package:aliskanlik_takibi/features/motivation/motivation_controller.dart';
import 'package:aliskanlik_takibi/features/notifications/notification_controller.dart';
import 'package:aliskanlik_takibi/features/pomodoro/pomodoro_controller.dart';
import 'package:aliskanlik_takibi/features/profile/settings_controller.dart';

Widget _buildTestApp({
  required Widget child,
  required AuthController authController,
  required HabitController habitController,
  required NotificationController notificationController,
  required MotivationController motivationController,
  required CompletionFeedbackController feedbackController,
  required SettingsController settingsController,
  required PomodoroController pomodoroController,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<HabitController>.value(value: habitController),
      ChangeNotifierProvider<NotificationController>.value(
        value: notificationController,
      ),
      ChangeNotifierProvider<MotivationController>.value(
        value: motivationController,
      ),
      ChangeNotifierProvider<CompletionFeedbackController>.value(
        value: feedbackController,
      ),
      ChangeNotifierProvider<SettingsController>.value(
        value: settingsController,
      ),
      ChangeNotifierProvider<PomodoroController>.value(
        value: pomodoroController,
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStore store;
  late LocalAuthRepository authRepo;
  late LocalHabitRepository habitRepo;
  late LocalPomodoroRepository pomodoroRepo;
  late MotivationRepository motivationRepo;

  late AuthController authCtrl;
  late HabitController habitCtrl;
  late NotificationController notifCtrl;
  late MotivationController motivationCtrl;
  late CompletionFeedbackController feedbackCtrl;
  late SettingsController settingsCtrl;
  late PomodoroController pomodoroCtrl;

  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = LocalStore();
    final seeded = await DemoSeed().applySeedIfNeeded(
      await store.load(),
      DateTime.now(),
    );
    await store.save(seeded);

    authRepo = LocalAuthRepository(store: store);
    habitRepo = LocalHabitRepository(store: store);
    pomodoroRepo = LocalPomodoroRepository(store: store);
    motivationRepo = MotivationRepository(habitRepository: habitRepo);

    authCtrl = AuthController(repository: authRepo);
    habitCtrl = HabitController(repository: habitRepo);
    notifCtrl = NotificationController(repository: habitRepo);
    motivationCtrl = MotivationController(repository: motivationRepo);
    feedbackCtrl = CompletionFeedbackController(
      motivationRepository: motivationRepo,
      motivationController: motivationCtrl,
    );
    settingsCtrl = SettingsController(store: store);
    pomodoroCtrl = PomodoroController(repository: pomodoroRepo);

    await authCtrl.login('demo@aliskanlik.com', 'demo1234');
    final user = authCtrl.currentUser!;
    await habitCtrl.loadUserData(user.id, '2026-10-23');
    await notifCtrl.loadReminders(user.id);
    await motivationCtrl.initUser(user.id);
    await settingsCtrl.initUser(user.id);
    await pomodoroCtrl.initUser(user.id);
  });

  testWidgets(
    'Bildirim kısmı dar ekranda (360px) açıldığında yatay taşma (overflow) yapmaz',
    (tester) async {
      // 360 x 640 ekran boyutu simülasyonu
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Okunmamış bildirim oluştur
      final user = authCtrl.currentUser!;
      await notifCtrl.checkAndGenerate(
        userId: user.id,
        habits: habitCtrl.activeHabits,
        todayKey: '2026-10-23',
        now: DateTime.now(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: const HomeScreen(),
          authController: authCtrl,
          habitController: habitCtrl,
          notificationController: notifCtrl,
          motivationController: motivationCtrl,
          feedbackController: feedbackCtrl,
          settingsController: settingsCtrl,
          pomodoroController: pomodoroCtrl,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Bildirim ikonunu bul ve tıkla
      final notifIconFinder = find.byTooltip('Hatırlatmalar');
      expect(notifIconFinder, findsOneWidget);
      await tester.tap(notifIconFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Modal Bottom Sheet'in açıldığını ve başlığın render edildiğini doğrula
      expect(find.text('Uygulama İçi Hatırlatmalar'), findsOneWidget);

      // Hiçbir taşma hatası olmamalı
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Bildirim okundu olarak işaretlendiğinde bildirimler kısmından kaldırılır',
    (tester) async {
      final user = authCtrl.currentUser!;
      await notifCtrl.checkAndGenerate(
        userId: user.id,
        habits: habitCtrl.activeHabits,
        todayKey: '2026-10-23',
        now: DateTime.now(),
      );
      expect(notifCtrl.activeReminders.isNotEmpty, isTrue);
      final initialCount = notifCtrl.activeReminders.length;

      await tester.pumpWidget(
        _buildTestApp(
          child: const HomeScreen(),
          authController: authCtrl,
          habitController: habitCtrl,
          notificationController: notifCtrl,
          motivationController: motivationCtrl,
          feedbackController: feedbackCtrl,
          settingsController: settingsCtrl,
          pomodoroController: pomodoroCtrl,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Bildirim ikonunu aç
      await tester.tap(find.byTooltip('Hatırlatmalar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Hatırlatmaların listelendiğini doğrula
      expect(find.byType(Dismissible), findsNWidgets(initialCount));
      expect(find.text('Tümünü Oku'), findsOneWidget);

      // İlk bildirimin okundu butonuna tıkla
      final doneButtonFinder = find.byIcon(Icons.done_rounded).first;
      await tester.tap(doneButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Listeden 1 adet eksildiğini doğrula
      expect(find.byType(Dismissible), findsNWidgets(initialCount - 1));

      // Kalanlar için 'Tümünü Oku' tıkla
      if (initialCount > 1) {
        await tester.tap(find.text('Tümünü Oku'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Tüm bildirimler kaldırılmış olmalı ve boş durum gösterilmeli
      expect(find.byType(Dismissible), findsNothing);
      expect(find.text('Henüz aktif bir hatırlatma yok.'), findsOneWidget);
      expect(notifCtrl.unreadCount, equals(0));
    },
  );
}
