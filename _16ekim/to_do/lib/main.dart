import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/task_model.dart';
import 'screens/01_today_screen.dart';
import 'screens/02_tasks_list_screen.dart';
import 'screens/03_task_form_screen.dart';

void main() => runApp(const DailyPlannerApp());

class DailyPlannerApp extends StatelessWidget {
  const DailyPlannerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Günlük Planım',
    locale: const Locale('tr'),
    supportedLocales: const [Locale('tr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: const PlannerNavigationHub(),
  );
}

class PlannerNavigationHub extends StatefulWidget {
  const PlannerNavigationHub({super.key});
  @override
  State<PlannerNavigationHub> createState() => _PlannerNavigationHubState();
}

class _PlannerNavigationHubState extends State<PlannerNavigationHub> {
  int _currentIndex = 0;
  int _nextId = 2;
  late final List<Task> _tasks;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _tasks = [
      Task(
        id: '0',
        title: 'Günlük tekrar',
        category: TaskCategory.study,
        scheduledAt: DateTime(now.year, now.month, now.day, 9),
        priority: TaskPriority.high,
        note: 'Bugün öğrendiklerini 30 dakika tekrar et.',
      ),
      Task(
        id: '1',
        title: 'Spor',
        category: TaskCategory.exercise,
        scheduledAt: DateTime(now.year, now.month, now.day, 18),
        note: 'Kendine uygun bir egzersiz için zaman ayır.',
      ),
    ];
  }

  void _toggle(Task task) =>
      setState(() => task.isCompleted = !task.isCompleted);

  void _add(
    String title,
    TaskCategory category,
    DateTime date,
    TaskPriority priority,
    String note,
  ) {
    setState(() {
      _tasks.add(
        Task(
          id: '${_nextId++}',
          title: title,
          category: category,
          scheduledAt: date,
          priority: priority,
          note: note,
        ),
      );
      _currentIndex = 1;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Görev eklendi.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(['Günlük Planım', 'Görevlerim', 'Görev Ekle'][_currentIndex]),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(
            index: _currentIndex,
            children: [
              TodayScreen(
                tasks: _tasks,
                onToggle: _toggle,
                onAdd: () => setState(() => _currentIndex = 2),
              ),
              TasksListScreen(tasks: _tasks, onToggle: _toggle),
              TaskFormScreen(onSave: _add),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Bugün',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_rounded),
          label: 'Görevlerim',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Görev Ekle',
        ),
      ],
    ),
  );
}
