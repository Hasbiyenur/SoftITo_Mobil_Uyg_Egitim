import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_spacing.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/empty_view.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? currentUser;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favori İlanlarım',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          if (state is ListingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = state is ListingLoaded ? state.favorites : [];

          if (favorites.isEmpty) {
            return const EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'Henüz Favori İlanınız Yok',
              subtitle: 'Keşfet ekranında beğendiğiniz ilanların kalp simgesine tıklayarak favorilerinize ekleyebilirsiniz.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final listing = favorites[index];
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
                  }, childCount: favorites.length),
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
