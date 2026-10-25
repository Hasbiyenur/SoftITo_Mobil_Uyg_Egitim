import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/app_logo.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';

/// Uygulama açılışında gösterilen Splash (Açılış/Karşılama) ekranı.
/// Roomio logosunu ölçekleme ve solma animasyonlarıyla sunar, arka planda kullanıcı oturumunu denetler.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 1200 milisaniyelik yumuşak açılış animasyonu başlatılır
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Dışa doğru yaylanan ölçek animasyonu
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    // Şeffaflıktan görünürlüğe geçiş animasyonu
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    // 1800 ms sonra oturum kontrolü (CheckAuthSessionEvent) tetiklenir
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthSessionEvent());
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AuthBloc'tan gelen duruma göre oturum varsa Ana Sayfaya, yoksa Giriş Ekranına yönlendirir
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        } else if (state is UnauthenticatedState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const AppLogo(size: 80),
            ),
          ),
        ),
      ),
    );
  }
}
