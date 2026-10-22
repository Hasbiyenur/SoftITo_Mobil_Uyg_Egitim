import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/local_store.dart';
import '../core/time/date_key.dart';
import '../core/widgets/app_logo.dart';
import '../data/demo/demo_seed.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/habits/habit_controller.dart';
import '../features/motivation/motivation_controller.dart';
import '../features/notifications/notification_controller.dart';
import 'main_shell.dart';

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final localStore = context.read<LocalStore>();
    final authCtrl = context.read<AuthController>();
    final habitCtrl = context.read<HabitController>();
    final notifCtrl = context.read<NotificationController>();
    final motivationCtrl = context.read<MotivationController>();

    try {
      // 1. Dokümanı yükle
      final doc = await localStore.load();

      // 2. Demo tohumunu gerekirse uygula
      final seededDoc = await DemoSeed().applySeedIfNeeded(doc, DateTime.now());
      if (seededDoc != doc) {
        await localStore.save(seededDoc);
      }

      // 3. Oturumu başlat
      await authCtrl.init();

      if (authCtrl.isAuthenticated) {
        final user = authCtrl.currentUser!;
        final todayKey = DateKey.today().value;
        await habitCtrl.loadUserData(user.id, todayKey);
        await notifCtrl.loadReminders(user.id);
        await notifCtrl.checkAndGenerate(
          userId: user.id,
          habits: habitCtrl.activeHabits,
          todayKey: todayKey,
          now: DateTime.now(),
        );
        await motivationCtrl.initUser(user.id);

        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 80),
            SizedBox(height: 28),
            CircularProgressIndicator(strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
