import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/listing/listing_bloc.dart';
import '../../bloc/listing/listing_event.dart';
import '../../bloc/listing/listing_state.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/rental_booking_bottom_sheet.dart';
import '../detail/listing_detail_screen.dart';

/// Kullanıcının beğendiği ve favorilerine eklediği ilanları listeleyen ekran.
/// Favori listesi boş olduğunda yönlendirici boş durum (empty state) tasarımı sunar.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    // Öğrenci indirimi durumu
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;
    final isStudent = user?.isStudent ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori İlanlarım'),
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          if (state is ListingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListingLoadedState) {
            // Sadece favori ID'leri ile eşleşen ilanları al
            final favorites = state.favoriteListings;

            // Favori listesi boşsa bilgi mesajı göster
            if (favorites.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Henüz favori ilanınız yok',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keşfet sayfasındaki ilanların üzerindeki kalp simgesine dokunarak favorilerinize ekleyebilirsiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Favori ilanlar 2 sütunlu ızgarada listelenir
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return ListingCard(
                    listing: item,
                    isFavorite: true,
                    isStudent: isStudent,
                    onFavoriteTap: () {
                      context
                          .read<ListingBloc>()
                          .add(ToggleFavoriteEvent(item.id));
                    },
                    onInspectTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: item),
                        ),
                      );
                    },
                    onRentTap: () {
                      RentalBookingBottomSheet.show(context, item);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
