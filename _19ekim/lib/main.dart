import 'package:flutter/material.dart';
import 'core/constants/app_color.dart';
import 'core/theme/app_theme.dart';
import 'features/water_tracker/controller/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controller/workout_controller.dart';
import 'features/workout/view/workout_view.dart';
import 'features/sleeptimer/controller/sleep_controller.dart';
import 'features/sleeptimer/view/sleeptimer_view.dart';

void main() {
  runApp(const SusadimApp());
}

class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Susadım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootNavigationShell(),
    );
  }
}

class RootNavigationShell extends StatefulWidget {
  const RootNavigationShell({super.key});

  @override
  State<RootNavigationShell> createState() => _RootNavigationShellState();
}

class _RootNavigationShellState extends State<RootNavigationShell> {
  int _currentIndex = 0;
  final WaterTrackerController _waterController = WaterTrackerController();
  final WorkoutController _workoutController = WorkoutController();
  final SleepController _sleepController = SleepController();

  @override
  void dispose() {
    _waterController.dispose();
    _workoutController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _AppBarTitle(index: _currentIndex),
        actions: const [
          _HeaderGlowBadge(),
          SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WaterTrackerView(controller: _waterController),
          WorkoutView(controller: _workoutController),
          SleeptimerView(controller: _sleepController),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon:
                Icon(Icons.water_drop_rounded, color: AppColor.neonCyan),
            label: 'Su Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon:
                Icon(Icons.fitness_center_rounded, color: AppColor.neonLime),
            label: 'Egzersiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            selectedIcon:
                Icon(Icons.bedtime_rounded, color: AppColor.neonPurple),
            label: 'Uyku',
          ),
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final title = switch (index) {
      0 => 'SUSADIM',
      1 => 'AKTİVİTE',
      _ => 'UYKU ZAMANI',
    };
    final subtitle = switch (index) {
      0 => 'Su Takibi',
      1 => 'Egzersiz & Kalori',
      _ => 'Uyku & Dinlenme',
    };
    final accent = switch (index) {
      0 => AppColor.neonCyan,
      1 => AppColor.neonLime,
      _ => AppColor.neonPurple,
    };

    return Row(
      children: [
        _LogoIcon(accentColor: accent),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
            Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(60),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.5),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _HeaderGlowBadge extends StatelessWidget {
  const _HeaderGlowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: AppColor.neonLime, size: 16),
          SizedBox(width: 4),
          Text(
            'CANLI',
            style: TextStyle(
              color: AppColor.neonLime,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
