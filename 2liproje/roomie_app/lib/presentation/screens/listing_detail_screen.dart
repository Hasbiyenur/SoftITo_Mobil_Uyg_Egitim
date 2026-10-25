import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/rental_booking_bottom_sheet.dart';
import 'chat_conversation_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  final UserModel? currentUser;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.currentUser,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _startChat(BuildContext context, ListingModel listing, UserModel user) {
    context.read<ChatBloc>().add(
      StartChatWithListingOwnerEvent(listing: listing, currentUser: user),
    );

    // Wait a brief tick for state to update, then navigate to conversation
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!context.mounted) return;
      final chatState = context.read<ChatBloc>().state;
      if (chatState is ChatLoaded && chatState.activeConversation != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(
              conversation: chatState.activeConversation!,
              currentUser: user,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          ListingModel? listing;
          if (state is ListingLoaded) {
            listing = state.allListings
                .where((l) => l.id == widget.listingId)
                .firstOrNull;
          }

          if (listing == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('İlan bulunamadı.')),
            );
          }

          final images = listing.images.isNotEmpty ? listing.images : [''];
          final isStudent = widget.currentUser?.isStudent ?? false;
          final isDiscounted = listing.isWinterCityEligible || isStudent;

          return CustomScrollView(
            slivers: [
              // Hero App Bar with Image Carousel
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _imageController,
                        onPageChanged: (i) =>
                            setState(() => _currentImageIndex = i),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return _buildImage(images[index]);
                        },
                      ),
                      // Top gradient for readable back button
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Page indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: _currentImageIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  // Favorite Button
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        listing.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: listing.isFavorite
                            ? AppColors.error
                            : Colors.black87,
                      ),
                      onPressed: () {
                        context.read<ListingBloc>().add(
                          ToggleFavoriteEvent(listing!.id),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Listing Details Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Home Type
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${listing.neighborhood}, ${listing.district} / ${listing.city}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price & Discount Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: AppRadius.cardRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aylık Kira Bedeli',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatMonthly(
                                        listing.monthlyPrice,
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${CurrencyFormatter.formatDaily(listing.dailyPrice)})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isDiscounted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isStudent && listing.isWinterCityEligible
                                      ? '-%40 İndirim Fırsatı'
                                      : '-%20 İndirimli',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Owner Information Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppRadius.cardRadius,
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              backgroundImage: listing.owner.avatar != null
                                  ? NetworkImage(listing.owner.avatar!)
                                  : null,
                              child: listing.owner.avatar == null
                                  ? Text(
                                      listing.owner.fullName.isNotEmpty
                                          ? listing.owner.fullName[0]
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        listing.owner.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: AppColors.info,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${listing.owner.occupation} • ${listing.owner.age} yaş',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${listing.owner.rating.toStringAsFixed(1)} Değerlendirme Puanı',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // İletişime Geç (Section 5: "İlan sahibi ile iletişime geçme butonu")
                            IconButton.filledTonal(
                              icon: const Icon(Icons.chat_bubble_rounded),
                              tooltip: 'Mesaj Gönder',
                              onPressed: () {
                                if (widget.currentUser != null) {
                                  _startChat(
                                    context,
                                    listing!,
                                    widget.currentUser!,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Mesaj gönderebilmek için oturum açınız.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Roommate & Living Preferences Section
                      const Text(
                        'Ev & Yaşam Kuralları',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag(
                            icon: Icons.pets_rounded,
                            label: listing.preferences.petFriendly
                                ? 'Evcil Hayvan Serbest'
                                : 'Evcil Hayvan Yok',
                            isPositive: listing.preferences.petFriendly,
                          ),
                          _buildTag(
                            icon: Icons.smoking_rooms_rounded,
                            label: listing.preferences.smokingAllowed
                                ? 'Sigara İçilebilir'
                                : 'Sigara İçilemez',
                            isPositive: listing.preferences.smokingAllowed,
                          ),
                          _buildTag(
                            icon: Icons.bedtime_rounded,
                            label:
                                'Uyku Düzeni: ${listing.preferences.sleepHabit}',
                            isPositive: true,
                          ),
                          _buildTag(
                            icon: Icons.cleaning_services_rounded,
                            label:
                                'Temizlik: ${listing.preferences.cleanliness}',
                            isPositive: true,
                          ),
                          _buildTag(
                            icon: Icons.translate_rounded,
                            label:
                                'Diller: ${listing.preferences.languages.join(", ")}',
                            isPositive: true,
                          ),
                          _buildTag(
                            icon: Icons.person_search_rounded,
                            label:
                                'Tercih Edilen: ${listing.preferences.preferredGender}',
                            isPositive: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Description
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        listing.description,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Bottom Action Bar with "Kirala" Button (Section 5)
      bottomNavigationBar: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          ListingModel? listing;
          if (state is ListingLoaded) {
            listing = state.allListings
                .where((l) => l.id == widget.listingId)
                .firstOrNull;
          }
          if (listing == null) return const SizedBox();
          final currentListing = listing;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.standard),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aylık',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatMonthly(currentListing.monthlyPrice),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: currentListing.isRented ? 'Kiralanmış İlan' : 'Hemen Kirala',
                    icon: Icons.calendar_month_rounded,
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      final effectiveUser = authState is Authenticated
                          ? authState.user
                          : widget.currentUser;

                      if (effectiveUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Kiralama yapabilmek için lütfen giriş yapınız.',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      if (currentListing.isRented) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Bu ilan zaten kiralanmış durumdadır.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      if (currentListing.owner.id.isNotEmpty &&
                          currentListing.owner.id == effectiveUser.id) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kendi ilanınızı kiralayamazsınız.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      RentalBookingBottomSheet.show(
                        context,
                        listing: currentListing,
                        currentUser: effectiveUser,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.shimmerBase,
        child: const Icon(Icons.home, size: 60),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: AppColors.shimmerBase),
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: AppColors.shimmerBase),
      );
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(color: AppColors.shimmerBase);
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required bool isPositive,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isPositive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
