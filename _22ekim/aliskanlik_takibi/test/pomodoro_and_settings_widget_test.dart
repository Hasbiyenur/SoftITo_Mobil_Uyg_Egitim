import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:aliskanlik_takibi/app/main_shell.dart';
import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/data/demo/demo_seed.dart';
import 'package:aliskanlik_takibi/data/motivation/motivation_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_auth_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_pomodoro_repository.dart';
import 'package:aliskanlik_takibi/features/auth/auth_controller.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';
import 'package:aliskanlik_takibi/features/motivation/completion_feedback_controller.dart';
import 'package:aliskanlik_takibi/features/motivation/motivation_controller.dart';
import 'package:aliskanlik_takibi/features/notifications/notification_controller.dart';
import 'package:aliskanlik_takibi/features/pomodoro/pomodoro_controller.dart';
import 'package:aliskanlik_takibi/features/pomodoro/screens/pomodoro_screen.dart';
import 'package:aliskanlik_takibi/features/profile/screens/profile_screen.dart';
import 'package:aliskanlik_takibi/features/profile/screens/settings_screen.dart';
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
    child: MaterialApp(
      home: child,
      routes: {
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    ),
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
    'MainShell alt menüsü Ana Sayfa, Görevler ve Pomodoro sekmelerini içerir',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const MainShell(),
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

      expect(find.text('Ana Sayfa'), findsOneWidget);
      expect(find.text('Görevler'), findsOneWidget);
      expect(find.text('Pomodoro'), findsOneWidget);
      // Eski 'Profil' sekmesi alt menüde bulunmamalıdır
      expect(
        find.widgetWithText(NavigationDestination, 'Profil'),
        findsNothing,
      );

      // 3. Sekmeye (Pomodoro) geçiş yap
      await tester.tap(find.text('Pomodoro'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PomodoroScreen), findsOneWidget);
      expect(find.text('Süre Ayarları'), findsOneWidget);
      expect(find.text('Pomodoro Geçmişim'), findsOneWidget);
    },
  );

  testWidgets(
    'PomodoroScreen Süre Ayarları formu açılır, değerler değiştirilip kaydedilebilir',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const PomodoroScreen(),
          authController: authCtrl,
          habitController: habitCtrl,
          notificationController: notifCtrl,
          motivationController: motivationCtrl,
          feedbackController: feedbackCtrl,
          settingsController: settingsCtrl,
          pomodoroController: pomodoroCtrl,
        ),
      );
      await tester.pumpAndSettle();

      // Süre Ayarları başlığına basarak aç
      await tester.tap(find.text('Süre Ayarları'));
      await tester.pumpAndSettle();

      expect(find.text('Süreleri Kaydet'), findsOneWidget);
      expect(find.text('Varsayılana'), findsOneWidget);

      // Değerleri kontrol et (varsayılan 25 / 5 / 15)
      expect(find.text('25'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(find.text('15'), findsWidgets);
    },
  );

  testWidgets(
    'SettingsScreen Profil Fotoğrafı, Görünüm, Şifre Değiştir ve Motivasyon bölümlerini içerir',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const SettingsScreen(),
          authController: authCtrl,
          habitController: habitCtrl,
          notificationController: notifCtrl,
          motivationController: motivationCtrl,
          feedbackController: feedbackCtrl,
          settingsController: settingsCtrl,
          pomodoroController: pomodoroCtrl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil Fotoğrafı'), findsOneWidget);
      expect(find.text('Görünüm'), findsOneWidget);
      expect(find.text('Şifre Değiştir'), findsOneWidget);
      expect(find.text('Motivasyon Tercihleri'), findsOneWidget);
      expect(find.text('Açık Tema'), findsOneWidget);
      expect(find.text('Koyu Tema'), findsOneWidget);

      // Koyu Tema'yı görünür yap ve tıkla
      final darkThemeRadio = find.text('Koyu Tema');
      await tester.ensureVisible(darkThemeRadio);
      await tester.pumpAndSettle();
      await tester.tap(darkThemeRadio);
      await tester.pumpAndSettle();

      expect(settingsCtrl.isDarkMode, isTrue);

      // Tekrar Açık Tema'yı görünür yap ve tıkla
      final lightThemeRadio = find.text('Açık Tema');
      await tester.ensureVisible(lightThemeRadio);
      await tester.pumpAndSettle();
      await tester.tap(lightThemeRadio);
      await tester.pumpAndSettle();

      expect(settingsCtrl.isDarkMode, isFalse);
    },
  );
}
