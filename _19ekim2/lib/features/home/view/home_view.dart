import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_logo_widget.dart';
import '../../water_tracker/controllers/water_tracker_controller.dart';
import '../../water_tracker/view/water_tracker_view.dart';
import '../../workout/controllers/workout_controller.dart';
import '../../workout/view/workout_view.dart';

class HomeView extends StatelessWidget {
  final WaterTrackerController waterController;
  final WorkoutController workoutController;
  final ThemeController themeController;
  final ValueNotifier<int> activeTab = ValueNotifier<int>(0);

  HomeView({
    super.key,
    required this.waterController,
    required this.workoutController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: activeTab,
      builder: (context, currentTabIndex, _) {
        return Scaffold(
          appBar: AppBar(
            title: const AppLogoWidget(size: 38),
            actions: [
              // Reaktif Karanlık / Aydınlık Mod Butonu
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeController.themeMode,
                builder: (context, currentMode, _) {
                  final isDark = currentMode == ThemeMode.dark;
                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        key: ValueKey<bool>(isDark),
                        color: isDark
                            ? AppColors.energyOrangeOf(context)
                            : AppColors.primaryAquaOf(context),
                      ),
                    ),
                    tooltip: isDark ? 'Aydınlık Moda Geç' : 'Karanlık Moda Geç',
                    onPressed: themeController.toggleTheme,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textSecondaryOf(context),
                ),
                tooltip: 'Hatırlatıcılar',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('💧 Su hatırlatıcısı her saat başı aktif!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.surfaceElevatedOf(context),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: IndexedStack(
              index: currentTabIndex,
              children: [
                WaterTrackerView(controller: waterController),
                WorkoutView(controller: workoutController),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.borderOf(context),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentTabIndex,
              onTap: (index) => activeTab.value = index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.water_drop_outlined),
                  activeIcon: Icon(Icons.water_drop_rounded),
                  label: 'Su Takibi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center_rounded),
                  label: 'Egzersiz',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
