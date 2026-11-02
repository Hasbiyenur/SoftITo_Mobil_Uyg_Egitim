import 'package:flutter/material.dart';
import 'features/diary/controllers/diary_controller.dart';
import 'features/diary/views/diary_home_view.dart';

/// Uygulama kök widget'ı.
/// DiaryController ve tema notifier yaşam döngüsünü burada yönetir.
class DiaryApp extends StatefulWidget {
  const DiaryApp({super.key});

  @override
  State<DiaryApp> createState() => _DiaryAppState();
}

class _DiaryAppState extends State<DiaryApp> {
  late final DiaryController _diaryController;
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void initState() {
    super.initState();
    _diaryController = DiaryController();
  }

  void _toggleTheme() {
    _themeMode.value = _themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  @override
  void dispose() {
    _diaryController.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Günlüğüm',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          home: DiaryHomeView(
            controller: _diaryController,
            onToggleTheme: _toggleTheme,
            themeMode: _themeMode,
          ),
        );
      },
    );
  }
}
