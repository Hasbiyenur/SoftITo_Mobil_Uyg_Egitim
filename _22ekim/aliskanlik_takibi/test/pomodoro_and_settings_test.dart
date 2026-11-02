import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/core/theme/app_colors.dart';
import 'package:aliskanlik_takibi/core/time/date_key.dart';
import 'package:aliskanlik_takibi/data/models/avatar_option.dart';
import 'package:aliskanlik_takibi/data/models/pomodoro_preferences.dart';
import 'package:aliskanlik_takibi/data/models/pomodoro_session.dart';
import 'package:aliskanlik_takibi/data/repositories/local_auth_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_pomodoro_repository.dart';
import 'package:aliskanlik_takibi/features/auth/auth_controller.dart';
import 'package:aliskanlik_takibi/features/pomodoro/pomodoro_controller.dart';
import 'package:aliskanlik_takibi/features/profile/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('Pomodoro Süre Doğrulama Testleri', () {
    test(
      'Çalışma süresi 1-180 arası geçerli, sınır dışı değerler hata döndürür',
      () {
        expect(PomodoroPreferences.validateFocusMinutes('25'), isNull);
        expect(PomodoroPreferences.validateFocusMinutes('1'), isNull);
        expect(PomodoroPreferences.validateFocusMinutes('180'), isNull);

        expect(PomodoroPreferences.validateFocusMinutes(''), isNotNull);
        expect(PomodoroPreferences.validateFocusMinutes('0'), isNotNull);
        expect(PomodoroPreferences.validateFocusMinutes('-5'), isNotNull);
        expect(PomodoroPreferences.validateFocusMinutes('181'), isNotNull);
        expect(PomodoroPreferences.validateFocusMinutes('25.5'), isNotNull);
        expect(PomodoroPreferences.validateFocusMinutes('abc'), isNotNull);
      },
    );

    test(
      'Kısa mola süresi 1-60 arası geçerli, sınır dışı değerler hata döndürür',
      () {
        expect(PomodoroPreferences.validateShortBreakMinutes('5'), isNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('1'), isNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('60'), isNull);

        expect(PomodoroPreferences.validateShortBreakMinutes(''), isNotNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('0'), isNotNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('-1'), isNotNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('61'), isNotNull);
        expect(PomodoroPreferences.validateShortBreakMinutes('5.2'), isNotNull);
      },
    );

    test('Uzun mola süresi 1-120 arası ve kısa moladan kısa olamaz', () {
      expect(PomodoroPreferences.validateLongBreakMinutes('15', 5), isNull);
      expect(PomodoroPreferences.validateLongBreakMinutes('5', 5), isNull);
      expect(PomodoroPreferences.validateLongBreakMinutes('120', 10), isNull);

      // Kısa moladan daha kısa olamaz
      expect(PomodoroPreferences.validateLongBreakMinutes('4', 5), isNotNull);
      expect(PomodoroPreferences.validateLongBreakMinutes('0', 5), isNotNull);
      expect(PomodoroPreferences.validateLongBreakMinutes('121', 5), isNotNull);
      expect(PomodoroPreferences.validateLongBreakMinutes('', 5), isNotNull);
    });
  });

  group('PomodoroController Döngü ve Süre Testleri', () {
    late LocalStore store;
    late LocalPomodoroRepository repo;
    late PomodoroController controller;

    setUp(() async {
      store = LocalStore();
      repo = LocalPomodoroRepository(store: store);
      controller = PomodoroController(repository: repo);
      await controller.initUser('test_user_1');
    });

    test('Başlangıçta varsayılan 25/5/15 süreleri ve hazır aşama yüklenir', () {
      expect(controller.preferences.focusMinutes, equals(25));
      expect(controller.preferences.shortBreakMinutes, equals(5));
      expect(controller.preferences.longBreakMinutes, equals(15));
      expect(controller.state.phase, equals('focus'));
      expect(controller.state.status, equals('ready'));
      expect(controller.state.remainingSeconds, equals(25 * 60));
    });

    test(
      'Henüz başlamamış hazır aşamada süre kaydedilirse sayaç güncellenir',
      () async {
        await controller.saveCustomDurations(
          focusMinutes: 45,
          shortBreakMinutes: 8,
          longBreakMinutes: 20,
        );

        expect(controller.preferences.focusMinutes, equals(45));
        expect(controller.preferences.shortBreakMinutes, equals(8));
        expect(controller.preferences.longBreakMinutes, equals(20));
        expect(controller.state.remainingSeconds, equals(45 * 60));
        expect(controller.state.plannedSeconds, equals(45 * 60));
        expect(controller.noticeMessage, isNull);
      },
    );

    test('Çalışan veya duraklatılmış aşamada süre kaydedildiğinde mevcut sayaç bozulmaz ve uyarı gösterilir', () async {
      await controller.start(title: 'Önemli Çalışma');
      expect(controller.state.isRunning, isTrue);

      await controller.saveCustomDurations(
        focusMinutes: 50,
        shortBreakMinutes: 10,
        longBreakMinutes: 25,
      );

      // Mevcut sayaç süresi 25 dakika olarak başlanan oturumda kalır
      expect(controller.state.plannedSeconds, equals(25 * 60));
      expect(
        controller.noticeMessage,
        equals('Yeni süreler sonraki aşamalarda kullanılacak.'),
      );
    });

    test(
      '4 tamamlanmış çalışma sonrası uzun mola döngü kuralı korunur',
      () async {
        // 1. Çalışma tamamlandı -> Kısa mola, döngü 1/4
        await controller.start();
        await controller.completePhase();
        expect(controller.state.phase, equals('shortBreak'));
        expect(controller.state.cycleCompletedCount, equals(1));

        // 1. Kısa mola bitti -> 2. Çalışma hazır
        await controller.completePhase();
        expect(controller.state.phase, equals('focus'));
        expect(controller.state.cycleCompletedCount, equals(1));

        // 2. Çalışma tamamlandı -> Kısa mola, döngü 2/4
        await controller.start();
        await controller.completePhase();
        expect(controller.state.phase, equals('shortBreak'));
        expect(controller.state.cycleCompletedCount, equals(2));

        // 2. Kısa mola bitti -> 3. Çalışma hazır
        await controller.completePhase();
        expect(controller.state.phase, equals('focus'));

        // 3. Çalışma tamamlandı -> Kısa mola, döngü 3/4
        await controller.start();
        await controller.completePhase();
        expect(controller.state.phase, equals('shortBreak'));
        expect(controller.state.cycleCompletedCount, equals(3));

        // 3. Kısa mola bitti -> 4. Çalışma hazır
        await controller.completePhase();
        expect(controller.state.phase, equals('focus'));

        // 4. Çalışma tamamlandı -> UZUN MOLA önerilir, döngü 4/4
        await controller.start();
        await controller.completePhase();
        expect(controller.state.phase, equals('longBreak'));
        expect(controller.state.cycleCompletedCount, equals(4));

        // Uzun mola bittiğinde döngü 0'a sıfırlanır
        await controller.completePhase();
        expect(controller.state.phase, equals('focus'));
        expect(controller.state.cycleCompletedCount, equals(0));
      },
    );

    test('Günlük odak dakikası tamamlanmış oturumların gerçek focusedSeconds toplamından hesaplanır', () async {
      final today = DateKey.today().value;

      // Özel süreli 40 dakikalık ve 30 dakikalık iki oturum ekle
      final s1 = PomodoroSession(
        id: 's1',
        userId: 'test_user_1',
        titleSnapshot: 'Çalışma 1',
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedOnDateKey: today,
        plannedSeconds: 40 * 60,
        focusedSeconds: 40 * 60,
        status: 'completed',
      );
      final s2 = PomodoroSession(
        id: 's2',
        userId: 'test_user_1',
        titleSnapshot: 'Çalışma 2',
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedOnDateKey: today,
        plannedSeconds: 30 * 60,
        focusedSeconds: 30 * 60,
        status: 'completed',
      );
      // Yarıda bırakılan oturum (günlük tamamlanmış sayısına ve tamamlanan dakikaya katılmaz)
      final s3 = PomodoroSession(
        id: 's3',
        userId: 'test_user_1',
        titleSnapshot: 'Yarıda Kalan',
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedAtUtc: DateTime.now().toUtc().toIso8601String(),
        endedOnDateKey: today,
        plannedSeconds: 25 * 60,
        focusedSeconds: 10 * 60,
        status: 'abandoned',
      );

      await repo.saveSession('test_user_1', s1);
      await repo.saveSession('test_user_1', s2);
      await repo.saveSession('test_user_1', s3);

      await controller.initUser('test_user_1');

      // Toplam tamamlanan oturum = 2 (s3 sayılmaz)
      expect(controller.todayCompletedPomodoroCount, equals(2));
      // Toplam odak süresi = (40*60 + 30*60) ~/ 60 = 70 dakika (sabit 25 ile çarpılmadı!)
      expect(controller.todayTotalFocusedMinutes, equals(70));
    });
  });

  group('Avatar ve Ayarlar Testleri', () {
    test('AvatarOption kataloğu 8 hazır insan/hayvan avatarı içerir', () {
      expect(AvatarOption.all.length, equals(8));
      final ids = AvatarOption.all.map((a) => a.id).toSet();
      expect(ids.contains('fox'), isTrue);
      expect(ids.contains('cat'), isTrue);
      expect(ids.contains('dog'), isTrue);
      expect(ids.contains('panda'), isTrue);
      expect(ids.contains('human_01'), isTrue);
      expect(ids.contains('human_02'), isTrue);
      expect(ids.contains('human_03'), isTrue);
      expect(ids.contains('human_04'), isTrue);
    });

    test(
      'Avatar seçimi güncellendiğinde AuthController ve depoda kalıcı olur',
      () async {
        final store = LocalStore();
        final authRepo = LocalAuthRepository(store: store);
        final authCtrl = AuthController(repository: authRepo);

        await authRepo.register(
          firstName: 'Ali',
          lastName: 'Yılmaz',
          email: 'ali@example.com',
          password: 'Password123!',
        );

        await authCtrl.login('ali@example.com', 'Password123!');
        expect(authCtrl.currentUser?.avatarId, equals('fox')); // varsayılan

        await authCtrl.updateAvatar('panda');
        expect(authCtrl.currentUser?.avatarId, equals('panda'));

        // Yeniden açılışta korunur
        final activeUser = await authRepo.getActiveUser();
        expect(activeUser?.avatarId, equals('panda'));
      },
    );

    test(
      'Tema değişimi ThemeMode günceller ve AppSettings olarak saklar',
      () async {
        final store = LocalStore();
        final settingsCtrl = SettingsController(store: store);

        await settingsCtrl.initUser('user_test_theme');
        expect(settingsCtrl.themeMode, equals(ThemeMode.light));

        await settingsCtrl.setThemeMode('user_test_theme', ThemeMode.dark);
        expect(settingsCtrl.themeMode, equals(ThemeMode.dark));
        expect(settingsCtrl.isDarkMode, isTrue);

        // Depoda saklandı mı?
        final doc = await store.load();
        expect(
          doc.appSettingsByUser['user_test_theme']?.themeMode,
          equals('dark'),
        );
      },
    );
  });

  group('Koyu Tema Renk Kontrastı ve Tasarım Testleri', () {
    test(
      'Koyu tema zemin ve kart renkleri şartnamedeki hex kodlarıyla örtüşür',
      () {
        expect(AppColors.darkBackground, equals(const Color(0xFF18201D)));
        expect(AppColors.darkSurface, equals(const Color(0xFF242D29)));
        expect(AppColors.darkPrimary, equals(const Color(0xFFAEC9A5)));
        expect(AppColors.darkOnBackground, equals(const Color(0xFFEEF3EF)));
        expect(AppColors.darkOnSurfaceVariant, equals(const Color(0xFFB7C5BC)));
        expect(AppColors.darkOutline, equals(const Color(0xFF3C4A42)));
      },
    );
  });
}
