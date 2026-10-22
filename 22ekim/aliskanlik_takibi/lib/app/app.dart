import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import 'bootstrap_screen.dart';
import 'main_shell.dart';

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alışkanlık Takibi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const BootstrapScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/main': (_) => const MainShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          final email = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => LoginScreen(initialEmail: email),
          );
        }
        if (settings.name == '/forgot-password') {
          final email = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => ForgotPasswordScreen(initialEmail: email),
          );
        }
        return null;
      },
    );
  }
}
