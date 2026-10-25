import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/listing_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/empty_view.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );
  int _activeBanner = 0;

  final List<Map<String, dynamic>> _campaignBanners = [
    {
      'title': 'Öğrenciye %20 Kira Desteği 🎓',
      'desc': 'Doğrulanmış öğrenci profillerinde kira bedelinin %20\'si Roomio tarafından karşılanır!',
      'tag': 'ÖĞRENCİ İNDİRİMİ',
      'color': AppColors.primary,
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Yeni Ev Sahiplerine %0 Komisyon 🏠',
      'desc': 'İlk defa odasını veya evini kiraya veren kullanıcılardan hiçbir servis komisyonu alınmaz.',
      'tag': 'YENİ KULLANICI',
      'color': const Color(0xFF2C3E50),
      'icon': Icons.celebration_rounded,
    },
    {
      'title': 'Kış Sezonu Seçili İllerde -%20 ❄️',
      'desc': 'Kasım - Ocak süresince İstanbul, Ankara ve İzmir ilanlarında anında %20 indirim fırsatı.',
      'tag': 'KIŞ SEZONU',
      'color': const Color(0xFF16A085),
      'icon': Icons.ac_unit_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.home_work_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Roomio',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // İlan Verme Butonu (Section 4: "İlan verme butonu ile ilan verme ekranına geçiş.")
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: () {
                if (currentUser != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateListingScreen(currentUser: currentUser!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'İlan verebilmek için lütfen oturum açınız.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'İlan Ver',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          if (state is ListingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListingError) {
            return Center(child: Text('Hata: ${state.message}'));
          }

          final listingState = state is ListingLoaded ? state : null;
          final listings = listingState?.filteredListings ?? [];
          final hasFilters = listingState?.hasActiveFilters ?? false;

          return CustomScrollView(
            slivers: [
              // Search & Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    8,
                    AppSpacing.screenMargin,
                    12,
                  ),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<ListingBloc>().add(
                              SearchQueryChangedEvent(val),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Şehir, ilçe veya oda ara...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<ListingBloc>().add(
                                        const SearchQueryChangedEvent(''),
                                      );
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Filter Button
                      Badge(
                        isLabelVisible: hasFilters,
                        backgroundColor: AppColors.secondary,
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasFilters
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFilters
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: hasFilters
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                            tooltip: 'Filtreler',
                            onPressed: () {
                              FilterBottomSheet.show(
                                context,
                                currentFilters:
                                    listingState?.filters ??
                                    const ListingFilterParams(),
                                onApply: (newFilters) {
                                  context.read<ListingBloc>().add(
                                    ApplyFiltersEvent(newFilters),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Campaign Banner Carousel (Section 4: "İndirim ve kampanyaların kaydırılabilir carousel yapısında gösterilmesi.")
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 125,
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (i) => setState(() => _activeBanner = i),
                        itemCount: _campaignBanners.length,
                        itemBuilder: (context, index) {
                          final b = _campaignBanners[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  b['color'] as Color,
                                  (b['color'] as Color).withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (b['color'] as Color).withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          b['tag'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        b['title'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        b['desc'] as String,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Icon(
                                    b['icon'] as IconData,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _campaignBanners.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _activeBanner == i ? 16 : 6,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _activeBanner == i
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.4,
                                  ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenMargin,
                    16,
                    AppSpacing.screenMargin,
                    10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mevcut İlanlar (${listings.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (hasFilters)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<ListingBloc>().add(
                              ResetFiltersEvent(),
                            );
                          },
                          child: const Text('Filtreleri Sıfırla'),
                        ),
                    ],
                  ),
                ),
              ),

              // Listings Grid
              if (listings.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    icon: Icons.search_off_rounded,
                    title: 'Aramanıza Uygun İlan Bulunamadı',
                    subtitle: 'Farklı filtre kriterleri belirleyebilir veya arama teriminizi değiştirebilirsiniz.',
                    buttonText: 'Filtreleri Temizle',
                    onButtonPressed: () {
                      _searchController.clear();
                      context.read<ListingBloc>().add(ResetFiltersEvent());
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenMargin,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.58,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        isStudentUser: currentUser?.isStudent ?? false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(
                                listingId: listing.id,
                                currentUser: currentUser,
                              ),
                            ),
                          );
                        },
                        onFavoriteToggle: () {
                          context.read<ListingBloc>().add(
                            ToggleFavoriteEvent(listing.id),
                          );
                        },
                      );
                    }, childCount: listings.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}
