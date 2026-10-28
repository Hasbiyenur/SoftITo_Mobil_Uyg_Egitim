import '../entities/listing_entity.dart';

/// İlan yönetimi, filtreleme ve favori işlemlerinin soyut sözleşmesi (Repository Interface).
abstract class ListingRepository {
  /// Sistemdeki tüm varsayılan ve kullanıcılar tarafından eklenen ilanları getirir.
  Future<List<ListingEntity>> getAllListings();

  /// Sisteme yeni bir ev/oda ilanı ekler.
  Future<void> addListing(ListingEntity listing);

  /// Kullanıcının favorilerine eklediği ilanların ID kümesini döner.
  Future<Set<String>> getFavoriteIds();

  /// Belirtilen ilanın favori durumunu tersine çevirir (varsa çıkarır, yoksa ekler).
  Future<void> toggleFavorite(String listingId);

  /// Belirli bir kullanıcı tarafından oluşturulmuş ilanları listeler.
  Future<List<ListingEntity>> getUserListings(String userId);

  /// Kullanıcının kendi ilanını aktif veya pasif duruma getirmesini sağlar.
  Future<void> toggleListingActive(String listingId);
}
