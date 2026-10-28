import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/listing_entity.dart';

/// İlanların liste veya ızgara görünümlerinde tek tek sunulduğu kart bileşeni.
/// Görsel, konum, indirim rozeti, favori butonu, başlık, fiyat dökümü ve 'İncele'/'Kirala' butonlarını barındırır.
class ListingCard extends StatelessWidget {
  /// Gösterilecek ev/oda ilanı
  final ListingEntity listing;

  /// İlanın kullanıcının favorilerinde olup olmadığı
  final bool isFavorite;

  /// Giriş yapan kullanıcının öğrenci olup olmadığı (İndirim hesaplamasını ekrana yansıtmak için)
  final bool isStudent;

  /// Favori butonuna basıldığında tetiklenen geri çağırım
  final VoidCallback onFavoriteTap;

  /// Kartın geneline veya 'İncele' butonuna basıldığında tetiklenen geri çağırım
  final VoidCallback onInspectTap;

  /// 'Kirala' butonuna basıldığında tetiklenen opsiyonel geri çağırım
  final VoidCallback? onRentTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    this.isStudent = false,
    required this.onFavoriteTap,
    required this.onInspectTap,
    this.onRentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Öğrenci indirimi (%20) veya kış dönemi indirimi (%20) hakkı kontrolü
    final bool hasDiscount = isStudent || listing.isWinterDiscountEligible;
    final double discountRate = hasDiscount ? 0.20 : 0.0;
    final double discountedPrice =
        listing.monthlyRent * (1.0 - discountRate);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
      ),
      child: InkWell(
        onTap: onInspectTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İlan Görseli ve Üzerindeki Rozetler (Stack)
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.network(
                    listing.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.accentBeige,
                      child: const Center(
                        child: Icon(Icons.home_work_rounded,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Konum Rozeti (İlçe, Şehir)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(170),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          '${listing.district}, ${listing.city}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favori Ekle / Çıkar Kalp Butonu
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onFavoriteTap,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Uygulanan İndirim Rozeti
                if (hasDiscount)
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isStudent ? '%20 Öğrenci İndirimi' : '%20 Kış İndirimi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // İlan Başlığı, Açıklaması ve Fiyat Alanı
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    listing.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textDark.withAlpha(160)
                          : AppColors.textLightSecondary.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Fiyat alanı: İndirim varsa üstü çizili eski fiyat ve yeni yeşil/turuncu fiyat
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          currencyFormat.format(listing.monthlyRent),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currencyFormat.format(discountedPrice),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ] else ...[
                        Text(
                          currencyFormat.format(listing.monthlyRent),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                      const Text(
                        ' /ay',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Aksiyon butonları: 'İncele' ve opsiyonel 'Kirala'
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            minimumSize: const Size.fromHeight(34),
                            textStyle: const TextStyle(fontSize: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onInspectTap,
                          child: const Text('İncele'),
                        ),
                      ),
                      if (onRentTap != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              minimumSize: const Size.fromHeight(34),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: onRentTap,
                            child: const Text('Kirala'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
