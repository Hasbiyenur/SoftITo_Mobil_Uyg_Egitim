import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

/// Yeni kullanıcılara uygulamanın sunduğu temel özellikleri (ev arkadaşı bulma, %20 öğrenci indirimi, güvenli mesajlaşma)
/// tanıtan çok adımlı Onboarding (Tanıtım) ekranı.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Tanıtım sayfalarının içerik listesi
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.people_alt_rounded,
      'title': 'İdeal Ev Arkadaşını Bul',
      'description':
          'Uyku düzeni, temizlik hassasiyeti ve alışkanlıklarına tam uyan ev veya oda arkadaşlarıyla eşleş.',
    },
    {
      'icon': Icons.savings_rounded,
      'title': 'Öğrencilere %20 İndirim',
      'description':
          'Öğrenci avantajları, sezonluk indirimler ve şeffaf günlük kiralama hesaplamalarıyla bütçeni koru.',
    },
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Güvenli Kiralama & Sohbet',
      'description':
          'Ev sahipleri ve kiracılarla doğrudan mesajlaş, aktif kiralamanı tek tıkla şeffafça yönet.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Üst Marka Logosu
              const AppLogo(size: 48, showText: true),
              const SizedBox(height: 20),
              // Kaydırılabilir Tanıtım Sayfaları (PageView)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.primaryDark.withAlpha(35)
                                  : AppColors.accentBeige,
                            ),
                            child: Icon(
                              page['icon'] as IconData,
                              size: 56,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['description'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.textDark.withAlpha(180)
                                  : AppColors.textLightSecondary.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Sayfa Belirteç Noktaları (Dots Indicator)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          : Colors.grey.withAlpha(80),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Giriş Yap ve Hesap Oluştur Butonları
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Hesap Oluştur'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
