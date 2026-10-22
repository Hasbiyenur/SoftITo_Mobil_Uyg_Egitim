import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/habits/habit_controller.dart';
import '../features/habits/screens/habits_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/motivation/completion_feedback_controller.dart';
import '../features/motivation/motivation_controller.dart';
import '../features/motivation/widgets/completion_banner.dart';
import '../features/motivation/widgets/completion_effect.dart';
import '../features/motivation/widgets/motivation_bubble.dart';
import '../features/motivation/widgets/motivation_mascot.dart';
import '../features/profile/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    HabitsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);

    // Tamamlama geri bildirimini HabitController'a bağla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final habitCtrl = context.read<HabitController>();
      final feedbackCtrl = context.read<CompletionFeedbackController>();
      final motivationCtrl = context.read<MotivationController>();

      habitCtrl.onHabitCelebration = ({required habit, required todayKey}) {
        final mode = motivationCtrl.preferences.completionFeedbackMode;
        feedbackCtrl.triggerCelebration(mode: mode, habitTitle: habit.title);
      };
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final motivationCtrl = context.read<MotivationController>();
    if (state == AppLifecycleState.resumed) {
      motivationCtrl.resume();
    } else {
      motivationCtrl.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motivationCtrl = context.watch<MotivationController>();
    final feedbackCtrl = context.watch<CompletionFeedbackController>();

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // Görevler sekmesinde altta eylem çubuğu olduğunda maskotu butonların üstüne yerleştir
    final mascotBottomOffset = _currentIndex == 1 ? 82.0 : 16.0;
    final bubbleBottomOffset = mascotBottomOffset + 64.0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Ana Sekmeler
          IndexedStack(index: _currentIndex, children: _pages),

          // 2. Kutlama Efekt Katmanı (Parıltı veya Alev)
          if (feedbackCtrl.isCelebrating &&
              (feedbackCtrl.activeCelebration == CelebrationType.sparkle ||
                  feedbackCtrl.activeCelebration == CelebrationType.flame))
            Positioned.fill(
              child: CompletionEffect(type: feedbackCtrl.activeCelebration),
            ),

          // 3. Üstten Kayan Motivasyon Tebrik Bandı
          if (feedbackCtrl.isCelebrating &&
              feedbackCtrl.activeCelebration == CelebrationType.message)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CompletionBanner(
                message: feedbackCtrl.activeMessage,
                onDismiss: feedbackCtrl.dismissNow,
              ),
            ),

          // 4. Konuşma Balonu (Maskotun üstünde/solunda)
          if (motivationCtrl.isBubbleVisible &&
              motivationCtrl.currentMessageText != null &&
              !isKeyboardOpen)
            Positioned(
              bottom: bubbleBottomOffset,
              right: 16,
              child: MotivationBubble(
                text: motivationCtrl.currentMessageText!,
                onDismiss: motivationCtrl.dismissBubble,
              ),
            ),

          // 5. Motivasyon Maskotu (Sağ alt köşe, alt menünün hemen üstü)
          if (motivationCtrl.isMascotEnabled && !isKeyboardOpen)
            Positioned(
              bottom: mascotBottomOffset,
              right: 16,
              child: MotivationMascot(onTap: motivationCtrl.onMascotTapped),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box_rounded),
            label: 'Görevler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
