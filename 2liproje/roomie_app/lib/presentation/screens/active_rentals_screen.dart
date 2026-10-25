import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/rental_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/rental_bloc.dart';
import '../widgets/checkout_photo_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_view.dart';
import 'chat_conversation_screen.dart';

class ActiveRentalsScreen extends StatefulWidget {
  const ActiveRentalsScreen({super.key});

  @override
  State<ActiveRentalsScreen> createState() => _ActiveRentalsScreenState();
}

class _ActiveRentalsScreenState extends State<ActiveRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _kirayaFilter = 'Tümü'; // 'Tümü', 'Aktif', 'Pasif'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCheckoutTapped(BuildContext context, RentalModel rental) {
    final now = DateTime.now();
    final isEarly = rental.endDate.isAfter(now);
    final daysStayed = now.difference(rental.startDate).inDays < 1
        ? 1
        : now.difference(rental.startDate).inDays;
    final dailyRate = rental.monthlyPrice / 30.0;
    final grossCharged = dailyRate * daysStayed;
    final studentDiscount = rental.isStudentDiscountApplied
        ? (grossCharged * 0.20)
        : 0.0;
    final winterDiscount = rental.isWinterDiscountApplied
        ? (grossCharged * 0.20)
        : 0.0;
    final actualCharged = grossCharged - studentDiscount - winterDiscount;
    final refund = (rental.totalPaid - actualCharged) > 0
        ? (rental.totalPaid - actualCharged)
        : 0.0;

    CheckoutPhotoDialog.show(
      context,
      rental: rental,
      isEarlyExit: isEarly,
      daysStayed: daysStayed,
      chargedAmount: actualCharged,
      refundAmount: refund,
      onConfirmed: (photoPath) {
        context.read<RentalBloc>().add(
          CompleteEarlyCheckoutEvent(
            rentalId: rental.id,
            checkoutPhotoPath: photoPath,
          ),
        );
      },
    );
  }

  void _chatWithOwner(
    BuildContext context,
    RentalModel rental,
    UserModel currentUser,
  ) {
    final chatBloc = context.read<ChatBloc>();
    final fakeListing = ListingModel(
      id: rental.listingId,
      title: rental.listingTitle,
      description: '',
      monthlyPrice: rental.monthlyPrice,
      city: rental.city,
      district: rental.district,
      neighborhood: '',
      images: [rental.listingImage],
      owner: ListingOwnerModel(
        id: rental.ownerId,
        fullName: rental.ownerName,
        age: 26,
        gender: 'Kadın',
        occupation: 'Ev Sahibi',
        phone: rental.ownerPhone,
      ),
      createdAt: DateTime.now(),
    );

    chatBloc.add(
      StartChatWithListingOwnerEvent(
        listing: fakeListing,
        currentUser: currentUser,
      ),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!context.mounted) return;
      final state = chatBloc.state;
      if (state is ChatLoaded && state.activeConversation != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(
              conversation: state.activeConversation!,
              currentUser: currentUser,
            ),
          ),
        );
      }
    });
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
        title: const Text(
          'Kiralamalarım & İlanlarım',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Kiralık Tuttuklarım'),
                Tab(text: 'Kiraya Verdiklerim'),
              ],
            ),
          ),
        ),
      ),
      body: BlocListener<RentalBloc, RentalState>(
        listener: (context, state) {
          if (state is RentalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is RentalActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildKiralikTuttuklarimTab(context, theme, currentUser),
            _buildKirayaVerdiklerimTab(context, theme, currentUser),
          ],
        ),
      ),
    );
  }

  // TAB 1: Kiralık Tuttuklarım (Single full-screen active rental view as per screen.md Section 7)
  Widget _buildKiralikTuttuklarimTab(
    BuildContext context,
    ThemeData theme,
    UserModel? currentUser,
  ) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        if (state is RentalLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final rentalLoaded = state is RentalLoaded ? state : null;
        final activeRental = rentalLoaded?.activeRental;
        final isActiveForUser = activeRental != null &&
            activeRental.isActive &&
            (currentUser == null || activeRental.tenantId == currentUser.id);

        if (!isActiveForUser) {
          return const EmptyView(
            icon: Icons.holiday_village_rounded,
            title: 'Aktif Kiralamanız Bulunmuyor',
            subtitle: 'Keşfet ekranındaki ilanları inceleyerek bütçenize uygun bir ev veya oda kiralayabilirsiniz.',
          );
        }

        final daysLeft = activeRental.daysRemaining;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Room Image & Status Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.cardRadius,
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: activeRental.listingImage.isNotEmpty
                          ? Image.network(
                              activeRental.listingImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.shimmerBase),
                            )
                          : Container(color: AppColors.shimmerBase),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Aktif Kiralama',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$daysLeft Gün Sonra Çıkış',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),

              // Title & Location
              Text(
                activeRental.listingTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${activeRental.district}, ${activeRental.city}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.standard),

              // Financial & Stay Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildRowDetail(
                      'Giriş Tarihi',
                      DateFormatter.formatShortDate(activeRental.startDate),
                    ),
                    const SizedBox(height: 8),
                    _buildRowDetail(
                      'Planlanan Çıkış',
                      DateFormatter.formatShortDate(activeRental.endDate),
                    ),
                    const SizedBox(height: 8),
                    _buildRowDetail(
                      'Toplam Süre',
                      '${activeRental.originalDays} gün (${activeRental.guestCount} kişi)',
                    ),
                    const SizedBox(height: 8),
                    _buildRowDetail(
                      'Ödenen Tutar (Peşin)',
                      CurrencyFormatter.format(activeRental.totalPaid),
                      isBold: true,
                    ),
                    if (activeRental.isStudentDiscountApplied) ...[
                      const SizedBox(height: 8),
                      _buildRowDetail(
                        'Öğrenci İndirimi',
                        '-%20 Uygulandı',
                        color: AppColors.success,
                      ),
                    ],
                    if (activeRental.isWinterDiscountApplied) ...[
                      const SizedBox(height: 8),
                      _buildRowDetail(
                        'Kış Sezon İndirimi',
                        '-%20 Uygulandı',
                        color: const Color(0xFF16A085),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.standard),

              // Owner Card & Chat Button
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        activeRental.ownerName.isNotEmpty
                            ? activeRental.ownerName[0]
                            : 'E',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ev Sahibi: ${activeRental.ownerName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            activeRental.ownerPhone,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                      ),
                      label: const Text(
                        'Mesaj',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        if (currentUser != null) {
                          _chatWithOwner(context, activeRental, currentUser);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Evden / Odadan Çıkış Yap Button (Section 7)
              CustomButton(
                text: 'Evden / Odadan Çıkış Yap',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.error,
                onPressed: () => _onCheckoutTapped(context, activeRental),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Çıkış öncesi evin son halinin fotoğrafı zorunludur.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // TAB 2: Kiraya Verdiklerim
  Widget _buildKirayaVerdiklerimTab(
    BuildContext context,
    ThemeData theme,
    UserModel? currentUser,
  ) {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, listingState) {
        final myListings = listingState is ListingLoaded
            ? listingState.myListings
            : <ListingModel>[];

        // Filter based on 'Aktif' / 'Pasif' status as per screen.md Section 7
        final filteredMyListings = myListings.where((l) {
          if (_kirayaFilter == 'Aktif') {
            return l.status == 'active';
          }
          if (_kirayaFilter == 'Pasif') {
            return l.status == 'inactive' || l.status == 'rented';
          }
          return true;
        }).toList();

        return BlocBuilder<RentalBloc, RentalState>(
          builder: (context, rentalState) {
            final allRentals = rentalState is RentalLoaded
                ? rentalState.allRentals
                : <RentalModel>[];

            return CustomScrollView(
              slivers: [
                // Filter Chips (Aktif / Pasif)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: ['Tümü', 'Aktif', 'Pasif'].map((cat) {
                        final isSelected = _kirayaFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _kirayaFilter = cat),
                            selectedColor: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                if (filteredMyListings.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(
                      icon: Icons.add_home_work_rounded,
                      title: 'Kiraya Verdiğiniz İlan Yok',
                      subtitle: 'Sahip olduğunuz evi veya odayı kiraya vermek için ana ekrandan "İlan Ver" butonuna tıklayabilirsiniz.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final listing = filteredMyListings[index];
                      // Check if this listing has an active rental
                      final activeBooking = allRentals
                          .where((r) => r.listingId == listing.id && r.isActive)
                          .firstOrNull;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Listing Header
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: listing.images.isNotEmpty
                                        ? Image.network(
                                            listing.images.first,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const Icon(Icons.home),
                                          )
                                        : const Icon(Icons.home),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listing.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${listing.district}, ${listing.city} • ${CurrencyFormatter.formatMonthly(listing.monthlyPrice)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: listing.status == 'active'
                                        ? AppColors.success.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.secondary.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    listing.status == 'active'
                                        ? 'Müsait / Aktif'
                                        : 'Dolu / Kirada',
                                    style: TextStyle(
                                      color: listing.status == 'active'
                                          ? AppColors.success
                                          : AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // If rented, show Tenant details card (Section 7: "Kiraya verilenler listesindeki kartlarda kullanıcı kiracı bilgilerini görüntülemelidir.")
                            if (activeBooking != null) ...[
                              const Divider(height: 20),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: theme
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.2),
                                          child: Text(
                                            activeBooking.tenantName[0],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Mevcut Kiracı: ${activeBooking.tenantName}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Kalış: ${DateFormatter.formatRange(activeBooking.startDate, activeBooking.endDate)}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Mesaj Gönder
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chat_bubble_rounded,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                          tooltip: 'Kiracıya Mesaj Gönder',
                                          onPressed: () {
                                            if (currentUser != null) {
                                              _chatWithTenant(
                                                context,
                                                activeBooking,
                                                currentUser,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Erken çıkış talep et butonu (Section 7)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(
                                          Icons.notification_important_rounded,
                                          size: 16,
                                          color: AppColors.error,
                                        ),
                                        label: const Text(
                                          'Erken Çıkış Talep Et',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.error,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.error,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (currentUser != null) {
                                            context.read<RentalBloc>().add(
                                              RequestEarlyExitTenantEvent(
                                                tenantId:
                                                    activeBooking.tenantId,
                                                tenantName:
                                                    activeBooking.tenantName,
                                                tenantAvatar:
                                                    activeBooking.tenantAvatar,
                                                listingTitle:
                                                    activeBooking.listingTitle,
                                                currentUser: currentUser,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }, childCount: filteredMyListings.length),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        );
      },
    );
  }

  void _chatWithTenant(
    BuildContext context,
    RentalModel rental,
    UserModel currentUser,
  ) {
    final chatBloc = context.read<ChatBloc>();
    final fakeListing = ListingModel(
      id: rental.listingId,
      title: rental.listingTitle,
      description: '',
      monthlyPrice: rental.monthlyPrice,
      city: rental.city,
      district: rental.district,
      neighborhood: '',
      images: [rental.listingImage],
      owner: ListingOwnerModel(
        id: rental.tenantId,
        fullName: rental.tenantName,
        age: 22,
        gender: rental.tenantGender,
        occupation: 'Kiracı',
        phone: '+90 5XX XXX XX XX',
      ),
      createdAt: DateTime.now(),
    );

    chatBloc.add(
      StartChatWithListingOwnerEvent(
        listing: fakeListing,
        currentUser: currentUser,
      ),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!context.mounted) return;
      final state = chatBloc.state;
      if (state is ChatLoaded && state.activeConversation != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(
              conversation: state.activeConversation!,
              currentUser: currentUser,
            ),
          ),
        );
      }
    });
  }

  Widget _buildRowDetail(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
