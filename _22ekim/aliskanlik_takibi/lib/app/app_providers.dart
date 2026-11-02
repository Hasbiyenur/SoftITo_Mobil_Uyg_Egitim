import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/security/demo_password_service.dart';
import '../core/storage/local_store.dart';
import '../data/motivation/motivation_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/local_auth_repository.dart';
import '../data/repositories/local_habit_repository.dart';
import '../data/repositories/local_pomodoro_repository.dart';
import '../data/repositories/pomodoro_repository.dart';
import '../features/auth/auth_controller.dart';
import '../features/habits/habit_controller.dart';
import '../features/motivation/completion_feedback_controller.dart';
import '../features/motivation/motivation_controller.dart';
import '../features/notifications/notification_controller.dart';
import '../features/pomodoro/pomodoro_controller.dart';
import '../features/profile/settings_controller.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStore>(create: (_) => LocalStore()),
        Provider<DemoPasswordService>(create: (_) => DemoPasswordService()),
        ProxyProvider2<LocalStore, DemoPasswordService, AuthRepository>(
          update: (_, store, passService, _) =>
              LocalAuthRepository(store: store, passwordService: passService),
        ),
        ProxyProvider<LocalStore, HabitRepository>(
          update: (_, store, _) => LocalHabitRepository(store: store),
        ),
        ProxyProvider<LocalStore, PomodoroRepository>(
          update: (_, store, _) => LocalPomodoroRepository(store: store),
        ),
        ProxyProvider<HabitRepository, MotivationRepository>(
          update: (_, habitRepo, _) =>
              MotivationRepository(habitRepository: habitRepo),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (ctx) => SettingsController(store: ctx.read<LocalStore>()),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthController>(
          create: (ctx) =>
              AuthController(repository: ctx.read<AuthRepository>()),
          update: (_, repo, prev) => prev ?? AuthController(repository: repo),
        ),
        ChangeNotifierProxyProvider<HabitRepository, HabitController>(
          create: (ctx) =>
              HabitController(repository: ctx.read<HabitRepository>()),
          update: (_, repo, prev) => prev ?? HabitController(repository: repo),
        ),
        ChangeNotifierProxyProvider<HabitRepository, NotificationController>(
          create: (ctx) =>
              NotificationController(repository: ctx.read<HabitRepository>()),
          update: (_, repo, prev) =>
              prev ?? NotificationController(repository: repo),
        ),
        ChangeNotifierProxyProvider<PomodoroRepository, PomodoroController>(
          create: (ctx) =>
              PomodoroController(repository: ctx.read<PomodoroRepository>()),
          update: (_, repo, prev) =>
              prev ?? PomodoroController(repository: repo),
        ),
        ChangeNotifierProxyProvider<MotivationRepository, MotivationController>(
          create: (ctx) => MotivationController(
            repository: ctx.read<MotivationRepository>(),
          ),
          update: (_, repo, prev) =>
              prev ?? MotivationController(repository: repo),
        ),
        ChangeNotifierProxyProvider2<
          MotivationRepository,
          MotivationController,
          CompletionFeedbackController
        >(
          create: (ctx) => CompletionFeedbackController(
            motivationRepository: ctx.read<MotivationRepository>(),
            motivationController: ctx.read<MotivationController>(),
          ),
          update: (_, repo, motCtrl, prev) =>
              prev ??
              CompletionFeedbackController(
                motivationRepository: repo,
                motivationController: motCtrl,
              ),
        ),
      ],
      child: child,
    );
  }
}
