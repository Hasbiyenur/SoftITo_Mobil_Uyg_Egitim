import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/listing/listing_bloc.dart';
import '../../bloc/listing/listing_event.dart';
import '../../bloc/listing/listing_state.dart';
import '../../widgets/campaign_carousel.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/listing_filter_bottom_sheet.dart';
import '../../widgets/rental_booking_bottom_sheet.dart';
import '../create_listing/create_listing_screen.dart';
import '../detail/listing_detail_screen.dart';

/// Keşfet (Ana Sayfa) Ekranı:
/// Uygulama logosu, 'İlan Ver' butonu, anlık arama çubuğu, gelişmiş filtreleme butonu,
/// kampanya afişleri (Carousel) ve 2 sütunlu ızgarada (Grid) listelenen ev/oda kartlarını barındırır.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    // Aktif kullanıcının öğrenci olup olmadığını öğrenerek kartlardaki indirimleri hesapla
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;
    final isStudent = user?.isStudent ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.roofing_rounded, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.textDark : AppColors.textLightPrimary,
                ),
                children: [
                  const TextSpan(text: 'Room'),
                  TextSpan(text: 'io', style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 'Yeni İlan Ver' butonu
          IconButton(
            tooltip: 'Yeni İlan Ver',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'İlan Ver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateListingScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          // İlanlar yüklenirken gösterge
          if (state is ListingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hata durumunda yeniden deneme ekranı
          if (state is ListingErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ListingBloc>().add(LoadListingsEvent()),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          // İlanlar başarıyla yüklendiğinde
          if (state is ListingLoadedState) {
            final listings = state.filteredListings;
            final isFilterActive = state.filters.isActive;

            return CustomScrollView(
              slivers: [
                // Arama Kutusu ve Filtreleme Butonu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              context
                                  .read<ListingBloc>()
                                  .add(SearchListingsEvent(query));
                            },
                            decoration: InputDecoration(
                              hintText: 'Şehir, ilçe veya ilan ara...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        context
                                            .read<ListingBloc>()
                                            .add(SearchListingsEvent(''));
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Filtreleme Butonu (Aktif filtre varsa dolu renkli ve noktalı)
                        Material(
                          color: isFilterActive
                              ? primaryColor
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ListingFilterBottomSheet.show(
                                  context, state.filters);
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isFilterActive
                                      ? primaryColor
                                      : Colors.grey.withAlpha(60),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    color: isFilterActive
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textDark
                                            : AppColors.textLightPrimary),
                                  ),
                                  if (isFilterActive)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Kampanyalar ve Fırsatlar Kayan Banner Alanı
                const SliverToBoxAdapter(
                  child: CampaignCarousel(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                // Bölüm Başlığı ve Bulunan İlan Sayısı
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFilterActive || _searchController.text.isNotEmpty
                              ? 'Arama Sonuçları'
                              : 'Öne Çıkan Ev & Oda İlanları',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${listings.length} İlan',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
                // İlan Listesi veya Sonuç Bulunamadı Görünümü
                listings.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: Colors.grey.withAlpha(120)),
                              const SizedBox(height: 12),
                              const Text(
                                'Kriterlerinize uygun ilan bulunamadı.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Filtreleri sıfırlayarak tekrar aramayı deneyin.',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ListingBloc>()
                                      .add(ClearFilterEvent());
                                },
                                child: const Text('Filtreleri Temizle'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = listings[index];
                              final isFav = state.favoriteIds.contains(item.id);

                              return ListingCard(
                                listing: item,
                                isFavorite: isFav,
                                isStudent: isStudent,
                                onFavoriteTap: () {
                                  context
                                      .read<ListingBloc>()
                                      .add(ToggleFavoriteEvent(item.id));
                                },
                                onInspectTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ListingDetailScreen(listing: item),
                                    ),
                                  );
                                },
                                onRentTap: () {
                                  RentalBookingBottomSheet.show(context, item);
                                },
                              );
                            },
                            childCount: listings.length,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
