import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/rento_logo.dart';
import '../widgets/vehicle_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Tümü';
  final List<String> _categories = [
    'Tümü',
    'Sedan',
    'SUV',
    'Elektrikli',
    'Hatchback',
    'Spor',
    'Ticari',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = AppStateScope.of(context);

    // Seçilen kategoriye göre filtreleme
    final vehicles = _selectedCategory == 'Tümü'
        ? appState.vehicles
        : appState.vehicles
            .where((v) => v.type.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const RentoLogo(
          size: 34,
          fontSize: 22,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hoş Geldiniz & İstatistik Başlığı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
                        : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.waving_hand_rounded,
                            color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Merhaba, ${appState.currentUserFirstName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'İhtiyacınıza uygun aracı saatlik kiralayın, dilediğiniz gibi yola çıkın.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickStat(
                          '${appState.vehicles.length} Araç',
                          'Müsait Filo',
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStat(
                          '${appState.myRentals.length} Kiralama',
                          'Aktif Kaydınız',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Kategori Seçim Şeridi
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF334155)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Araç Listesi
          if (vehicles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.directions_car_outlined,
                title: 'Araç Bulunamadı',
                message: '$_selectedCategory kategorisinde henüz araç bulunmuyor.',
                actionLabel: 'Tüm Araçları Göster',
                onActionPressed: () {
                  setState(() {
                    _selectedCategory = 'Tümü';
                  });
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final vehicle = vehicles[index];
                    return VehicleCard(vehicle: vehicle);
                  },
                  childCount: vehicles.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
