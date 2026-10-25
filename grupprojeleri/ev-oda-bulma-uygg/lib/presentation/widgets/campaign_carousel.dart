import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ana sayfada (HomeScreen) öne çıkan kampanyaları ve indirim fırsatlarını
/// otomatik kayan (slider/carousel) kartlar halinde gösteren dinamik bileşen.
class CampaignCarousel extends StatefulWidget {
  const CampaignCarousel({super.key});

  @override
  State<CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<CampaignCarousel> {
  final PageController _controller = PageController();
  int _activePage = 0;
  Timer? _timer;

  /// Tanıtılan kampanyaların etiket, başlık, açıklama ve renk paleti listesi
  final List<Map<String, dynamic>> _campaigns = [
    {
      'tag': 'ÖĞRENCİ AVANTAJI',
      'title': '%20 Öğrenci İndirimi',
      'description':
          'Öğrenci profiline sahip tüm kullanıcılara kiralamalarında anında %20 indirim uygulanır.',
      'gradient': [Color(0xFFE06A3B), Color(0xFFF39C12)],
      'icon': Icons.school_rounded,
    },
    {
      'tag': 'YENİ EV SAHİBİ',
      'title': '%0 Komisyon Fırsatı',
      'description':
          'Yeni kayıt olan ev/oda sahiplerinin ilk kiralamalarında sıfır komisyon avantajı!',
      'gradient': [Color(0xFF27AE60), Color(0xFF2ECC71)],
      'icon': Icons.stars_rounded,
    },
    {
      'tag': 'SEZON FIRSATI',
      'title': 'Kış Sezonu %20 İndirimi',
      'description':
          'Kasım - Ocak aylarında İstanbul, Ankara ve İzmir ilanlarında %20 kış indirimi geçerlidir.',
      'gradient': [Color(0xFF2980B9), Color(0xFF6DD5FA)],
      'icon': Icons.ac_unit_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Her 5 saniyede bir sonraki kampanya kartına otomatik geçiş sağlar
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients) {
        final nextPage = (_activePage + 1) % _campaigns.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _activePage = idx),
            itemCount: _campaigns.length,
            itemBuilder: (context, index) {
              final item = _campaigns[index];
              final gradient = item['gradient'] as List<Color>;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Kampanya metinleri ve etiket alanı
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(60),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['tag'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Kampanya ikonu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Sayfa göstergesi (Page Indicator Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _campaigns.length,
            (idx) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _activePage == idx ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _activePage == idx
                    ? AppColors.primaryLight
                    : Colors.grey.withAlpha(80),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
