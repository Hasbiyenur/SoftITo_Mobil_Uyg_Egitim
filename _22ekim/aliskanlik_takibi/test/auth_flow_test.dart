import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:aliskanlik_takibi/core/storage/local_store.dart';
import 'package:aliskanlik_takibi/data/demo/demo_seed.dart';
import 'package:aliskanlik_takibi/data/repositories/local_auth_repository.dart';
import 'package:aliskanlik_takibi/data/repositories/local_habit_repository.dart';
import 'package:aliskanlik_takibi/features/auth/auth_controller.dart';
import 'package:aliskanlik_takibi/features/auth/screens/forgot_password_screen.dart';
import 'package:aliskanlik_takibi/features/auth/screens/login_screen.dart';
import 'package:aliskanlik_takibi/features/auth/screens/register_screen.dart';
import 'package:aliskanlik_takibi/features/auth/screens/reset_password_screen.dart';
import 'package:aliskanlik_takibi/features/habits/habit_controller.dart';
import 'package:aliskanlik_takibi/features/notifications/notification_controller.dart';

Widget _buildTestApp({
  required Widget child,
  required AuthController authController,
  required HabitController habitController,
  required NotificationController notificationController,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<HabitController>.value(value: habitController),
      ChangeNotifierProvider<NotificationController>.value(
        value: notificationController,
      ),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Akış ve Ekran Testleri', () {
    late LocalStore store;
    late LocalAuthRepository authRepo;
    late AuthController authCtrl;
    late HabitController habitCtrl;
    late NotificationController notifCtrl;

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      store = LocalStore();
      authRepo = LocalAuthRepository(store: store);
      authCtrl = AuthController(repository: authRepo);
      final habitRepo = LocalHabitRepository(store: store);
      habitCtrl = HabitController(repository: habitRepo);
      notifCtrl = NotificationController(repository: habitRepo);

      // Demo verisini tohumla
      final initialDoc = await store.load();
      final seeded = await DemoSeed().applySeedIfNeeded(
        initialDoc,
        DateTime.now(),
      );
      await store.save(seeded);
    });

    test(
      'Demo tohumundan sonra başlangıçta aktif oturum olmamalıdır',
      () async {
        await authCtrl.init();
        expect(authCtrl.isAuthenticated, isFalse);
        expect(authCtrl.currentUser, isNull);
      },
    );

    test('Demo hesapla giriş ve çıkış akışı', () async {
      final success = await authCtrl.login('demo@aliskanlik.com', 'demo1234');
      expect(success, isTrue);
      expect(authCtrl.isAuthenticated, isTrue);
      expect(authCtrl.currentUser?.email, equals('demo@aliskanlik.com'));
      expect(authCtrl.currentUser?.firstName, equals('Hasbiyenur'));

      // Çıkış yap
      await authCtrl.logout();
      expect(authCtrl.isAuthenticated, isFalse);
      expect(authCtrl.currentUser, isNull);
    });

    test('Yeni kullanıcı kaydı ve tekrar eden e-posta kontrolü', () async {
      final ok = await authCtrl.register(
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        email: 'ahmet@test.com',
        password: 'password123',
      );
      expect(ok, isTrue);
      expect(
        authCtrl.successMessage,
        contains('Kaydın oluşturuldu. Şimdi giriş yapabilirsin.'),
      );

      // Aynı e-postayla tekrar kayıt engellenmeli
      final duplicate = await authCtrl.register(
        firstName: 'Ahmet 2',
        lastName: 'Yılmaz',
        email: 'ahmet@test.com',
        password: 'password456',
      );
      expect(duplicate, isFalse);
      expect(authCtrl.errorMessage, contains('zaten bir hesap oluşturulmuş'));
    });

    test(
      'Şifre sıfırlama kodu oluşturma, doğrulama ve yeni şifre kaydetme',
      () async {
        // 1. Bilinmeyen e-posta hata vermeli
        final fail = await authCtrl.requestResetCode('yok@posta.com');
        expect(fail, isFalse);
        expect(authCtrl.errorMessage, isNotNull);

        // 2. Demo e-posta için kod oluştur
        final ok = await authCtrl.requestResetCode('demo@aliskanlik.com');
        expect(ok, isTrue);
        final code = authCtrl.demoResetCode;
        expect(code, isNotNull);
        expect(code!.length, equals(6));

        // 3. Yanlış kod reddedilmeli
        final wrong = authCtrl.verifyResetCode('000000');
        expect(wrong, isFalse);
        expect(authCtrl.isResetCodeVerified, isFalse);

        // 4. Doğru kod onaylanmalı
        final verified = authCtrl.verifyResetCode(code);
        expect(verified, isTrue);
        expect(authCtrl.isResetCodeVerified, isTrue);

        // 5. Yeni şifre belirle ve kaydet
        final resetOk = await authCtrl.resetPassword('yeniSifre123');
        expect(resetOk, isTrue);
        expect(
          authCtrl.successMessage,
          contains('Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.'),
        );

        // 6. Yeni şifreyle giriş yapılabilmeli
        final loginOk = await authCtrl.login(
          'demo@aliskanlik.com',
          'yeniSifre123',
        );
        expect(loginOk, isTrue);
      },
    );

    testWidgets(
      'LoginScreen form alanları, butonlar ve gezinmeler görünür olmalı',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(
            child: const LoginScreen(),
            authController: authCtrl,
            habitController: habitCtrl,
            notificationController: notifCtrl,
          ),
        );
        await tester.pumpAndSettle();

        // Logo, e-posta, şifre ve butonlar kontrolü
        expect(find.text('E-posta'), findsOneWidget);
        expect(find.text('Şifre'), findsOneWidget);
        expect(find.text('Şifremi unuttum'), findsOneWidget);
        expect(find.text('Giriş Yap'), findsOneWidget);
        expect(find.text('Yeni Hesap Oluştur'), findsOneWidget);

        // "Yeni Hesap Oluştur" butonuna basınca RegisterScreen açılmalı
        await tester.tap(find.text('Yeni Hesap Oluştur'));
        await tester.pumpAndSettle();

        expect(find.text('Kayıt Ol'), findsOneWidget);
        expect(find.text('Ad'), findsOneWidget);
        expect(find.text('Soyad'), findsOneWidget);
        expect(find.text('Zaten hesabın var mı? Giriş yap'), findsOneWidget);

        // Geri dön
        await tester.ensureVisible(
          find.text('Zaten hesabın var mı? Giriş yap'),
        );
        await tester.tap(find.text('Zaten hesabın var mı? Giriş yap'));
        await tester.pumpAndSettle();

        expect(find.text('Giriş Yap'), findsOneWidget);

        // "Şifremi unuttum" bağlantısına basınca ForgotPasswordScreen açılmalı
        await tester.tap(find.text('Şifremi unuttum'));
        await tester.pumpAndSettle();

        expect(find.text('Şifremi Unuttum'), findsOneWidget);
        expect(find.text('Doğrulama Kodu Oluştur'), findsOneWidget);
      },
    );

    testWidgets(
      'ForgotPasswordScreen ve ResetPasswordScreen akışı arayüz testi',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(
            child: const ForgotPasswordScreen(
              initialEmail: 'demo@aliskanlik.com',
            ),
            authController: authCtrl,
            habitController: habitCtrl,
            notificationController: notifCtrl,
          ),
        );
        await tester.pumpAndSettle();

        // Kod oluştur butonuna tıkla
        await tester.tap(find.text('Doğrulama Kodu Oluştur'));
        await tester.pumpAndSettle();

        // Demo kodu görünüyor olmalı
        expect(authCtrl.demoResetCode, isNotNull);
        expect(find.text(authCtrl.demoResetCode!), findsOneWidget);

        // Koda dokunarak alana aktar
        await tester.tap(find.text(authCtrl.demoResetCode!));
        await tester.pumpAndSettle();

        // Kodu Doğrula butonuna bas
        expect(find.text('Kodu Doğrula'), findsOneWidget);
        await tester.ensureVisible(find.text('Kodu Doğrula'));
        await tester.tap(find.text('Kodu Doğrula'));
        await tester.pumpAndSettle();

        // Yeşil onay durumu ve İlerle butonu görünmeli
        expect(
          find.text('E-posta doğrulama demosu tamamlandı.'),
          findsOneWidget,
        );
        expect(find.text('İlerle'), findsOneWidget);

        // İlerle butonuna bas ve ResetPasswordScreen'e geç
        await tester.ensureVisible(find.text('İlerle'));
        await tester.tap(find.text('İlerle'));
        await tester.pumpAndSettle();

        expect(find.text('Yeni Şifre Oluştur'), findsOneWidget);
        expect(find.text('Yeni Şifre'), findsOneWidget);
        expect(find.text('Yeni Şifre Tekrar'), findsOneWidget);
        expect(find.text('Kaydet'), findsOneWidget);
      },
    );
  });
}
