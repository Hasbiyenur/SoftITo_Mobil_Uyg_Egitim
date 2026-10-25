import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'chat/chat_list_screen.dart';
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'rentals/active_rentals_screen.dart';

/// Uygulamanın ana gezinme kabuğu (Root Navigation Shell).
/// Alt gezinme çubuğu (Bottom Navigation Bar) ile 5 ana sekme arasında geçiş sağlar:
/// 1. Keşfet (HomeScreen)
/// 2. Favoriler (FavoritesScreen)
/// 3. Kiralamalar (ActiveRentalsScreen)
/// 4. Mesajlar (ChatListScreen)
/// 5. Profil (ProfileScreen)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Aktif seçili olan sekmenin indeksi
  int _currentIndex = 0;

  // Sekmelerin durumunu korumak için IndexedStack içinde tutulan sayfalar
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    ActiveRentalsScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      // Sayfalar arası geçişlerde scroll ve durum kaybını önlemek için IndexedStack kullanılır
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Material 3 standartlarında modern alt navigasyon çubuğu
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: primaryColor.withAlpha(40),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoriler',
          ),
          NavigationDestination(
            icon: Icon(Icons.key_outlined),
            selectedIcon: Icon(Icons.key_rounded),
            label: 'Kiralamalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Mesajlar',
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
