import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/listing_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/listing/listing_bloc.dart';
import '../../bloc/listing/listing_event.dart';
import '../../bloc/listing/listing_state.dart';
import '../../widgets/rental_booking_bottom_sheet.dart';
import '../chat/chat_conversation_screen.dart';

/// İlan Detay Ekranı:
/// İlanın büyük boy görseli (Hero AppBar), konum ve kış/öğrenci indirim rozetleri,
/// detaylı fiyat bilgisi, ilan sahibinin kartı ve doğrudan mesajlaşma butonu,
/// evin kuralları & oda arkadaşı alışkanlık kriterleri etiketleri
/// ve alt kısımda 'Mesaj Gönder' / 'Kirala' aksiyon çubuğunu içerir.
class ListingDetailScreen extends StatelessWidget {
  final ListingEntity listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Aktif kullanıcının öğrenci olup olmadığını kontrol et
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthenticatedState ? authState.user : null;
    final isStudent = user?.isStudent ?? false;

    // Öğrenci veya kış dönemi indirimi kontrolü (%20)
    final bool hasDiscount = isStudent || listing.isWinterDiscountEligible;
    final double discountRate = hasDiscount ? 0.20 : 0.0;
    final double discountedPrice =
        listing.monthlyRent * (1.0 - discountRate);

    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        // İlanın favoride olup olmadığını tespit et
        final isFavorite = state is ListingLoadedState &&
            state.favoriteIds.contains(listing.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Kaydırılabilir Büyük Görsel ve Favori Butonu (SliverAppBar)
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        listing.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) => Container(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.accentBeige,
                          child: const Center(
                            child: Icon(Icons.home_work_rounded,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Görsel üzeri karartma gradyanı
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(120),
                              Colors.transparent,
                              Colors.black.withAlpha(140),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      context
                          .read<ListingBloc>()
                          .add(ToggleFavoriteEvent(listing.id));
                    },
                  ),
                ],
              ),
              // Detay İçerik Alanı
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Konum ve İndirim Rozetleri
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 14, color: primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.district}, ${listing.city}',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (hasDiscount)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isStudent
                                    ? '%20 Öğrenci İndirimi'
                                    : '%20 Kış İndirimi',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // İlan Başlığı
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Fiyat Dökümü
                      Row(
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              currencyFormat.format(listing.monthlyRent),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currencyFormat.format(discountedPrice),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ] else ...[
                            Text(
                              currencyFormat.format(listing.monthlyRent),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                          const Text(
                            ' /ay',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      // İlan Sahibi Bilgi Kartı
                      const Text(
                        'İlan Sahibi',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.accentBeige.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.black.withAlpha(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  NetworkImage(listing.owner.avatarUrl),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.owner.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${listing.owner.occupation} • ${listing.owner.gender}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            // Hızlı sohbet başlatma butonu
                            IconButton.filledTonal(
                              icon: const Icon(Icons.chat_outlined),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatConversationScreen(
                                      peerId: listing.owner.id,
                                      peerName: listing.owner.name,
                                      peerAvatarUrl: listing.owner.avatarUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // İlan Açıklama Metni
                      const Text(
                        'Açıklama',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.description,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.6,
                          color: isDark
                              ? AppColors.textDark.withAlpha(200)
                              : AppColors.textLightSecondary.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Ev Arkadaşı Kriterleri ve Alışkanlık Etiketleri
                      const Text(
                        'Oda Arkadaşı Tercihleri & Kurallar',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTraitChip(
                            Icons.pets_rounded,
                            listing.preferences.petAllowed
                                ? 'Evcil Hayvan Serbest'
                                : 'Evcil Hayvan Yok',
                            listing.preferences.petAllowed
                                ? AppColors.success
                                : Colors.grey,
                          ),
                          _buildTraitChip(
                            Icons.smoke_free_rounded,
                            listing.preferences.smokingAllowed
                                ? 'Sigara İçilebilir'
                                : 'Sigara İçilmez',
                            listing.preferences.smokingAllowed
                                ? Colors.orange
                                : AppColors.success,
                          ),
                          _buildTraitChip(
                            Icons.bedtime_rounded,
                            'Uyku: ${listing.preferences.sleepSchedule}',
                            primaryColor,
                          ),
                          _buildTraitChip(
                            Icons.cleaning_services_rounded,
                            'Temizlik: ${listing.preferences.cleaningSensitivity}',
                            primaryColor,
                          ),
                          ...listing.preferences.languages.map(
                            (lang) => _buildTraitChip(
                              Icons.translate_rounded,
                              lang,
                              primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Alt Sabit Eylem Çubuğu: 'Mesaj Gönder' ve 'Kirala'
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Mesaj Gönder'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatConversationScreen(
                              peerId: listing.owner.id,
                              peerName: listing.owner.name,
                              peerAvatarUrl: listing.owner.avatarUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.key_rounded),
                      label: const Text('Kirala'),
                      onPressed: () {
                        RentalBookingBottomSheet.show(context, listing);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Kriter ve kural rozetlerini oluşturan yardımcı widget
  Widget _buildTraitChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
