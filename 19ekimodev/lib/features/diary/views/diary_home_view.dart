import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../widgets/app_logo.dart';
import 'diary_editor_view.dart';
import 'diary_list_view.dart';

/// Ana iskelet ekranı.
/// NavigationBar ile sekmeleri yönetir ve AppBar üzerinde logo ile tema değiştirme butonunu barındırır.
class DiaryHomeView extends StatefulWidget {
  final DiaryController controller;
  final VoidCallback onToggleTheme;
  final ValueNotifier<ThemeMode> themeMode;

  const DiaryHomeView({
    super.key,
    required this.controller,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<DiaryHomeView> createState() => _DiaryHomeViewState();
}

class _DiaryHomeViewState extends State<DiaryHomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                onPressed: widget.onToggleTheme,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DiaryEditorView(controller: widget.controller),
          DiaryListView(
            controller: widget.controller,
            onEntrySelected: (_) {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_rounded),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Günlük Yaz',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded),
            label: 'Günlüklerim',
          ),
        ],
      ),
    );
  }
}
