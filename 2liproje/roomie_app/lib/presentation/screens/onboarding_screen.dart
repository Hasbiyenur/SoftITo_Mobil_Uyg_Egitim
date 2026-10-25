import 'package:flutter/material.dart';

import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Mükemmel Ev & Oda Arkadaşını Bul',
      'description': 'Yaşam tarzına, alışkanlıklarına ve bütçene en uygun ev arkadaşını keşfet. Sıcak, güvenli ve düzenli bir ev ortamı yarat.',
    },
    {
      'title': 'Öğrenci & Sezon İndirimleri',
      'description': 'Doğrulanmış öğrenci profiline %20 kira desteği ve seçili büyükşehirlerde kış sezonu indirimleriyle bütçeni koru.',
    },
    {
      'title': 'Güvenli Kiralama & Şeffaf Süreç',
      'description': 'Adli sicil belgesi doğrulamalı üyeler, tek aktif kiralama güvencesi ve çıkış fotoğrafı onaylı taşınma süreciyle için rahat olsun.',
    },
  ];

  void _onFinish() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.standard,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              // Top Bar with Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Roomio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _onFinish,
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Hero Illustration
              Expanded(
                flex: 5,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/onboarding.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Carousel Details
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          final page = _pages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  page['title']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  page['description']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Dot Indicators
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
                            color: _currentPage == index
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Next / Start Button
                    CustomButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Hemen Başla'
                          : 'Devam Et',
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _onFinish();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
