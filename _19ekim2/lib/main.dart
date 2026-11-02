import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/view/home_view.dart';
import 'features/water_tracker/controllers/water_tracker_controller.dart';
import 'features/workout/controllers/workout_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SusadimApp());
}

class SusadimApp extends StatefulWidget {
  const SusadimApp({super.key});

  @override
  State<SusadimApp> createState() => _SusadimAppState();
}

class _SusadimAppState extends State<SusadimApp> {
  late final WaterTrackerController _waterController;
  late final WorkoutController _workoutController;
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _waterController = WaterTrackerController();
    _workoutController = WorkoutController();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _workoutController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController.themeMode,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Susadım v1',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: HomeView(
            waterController: _waterController,
            workoutController: _workoutController,
            themeController: _themeController,
          ),
        );
      },
    );
  }
}
