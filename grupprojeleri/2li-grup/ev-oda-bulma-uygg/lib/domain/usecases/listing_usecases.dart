import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

/// Sistemdeki tüm aktif ev ve oda ilanlarını listeleyen Use Case.
class GetAllListingsUseCase {
  final ListingRepository repository;
  GetAllListingsUseCase(this.repository);

  /// Tüm ilanların listesini getirir.
  Future<List<ListingEntity>> execute() => repository.getAllListings();
}

/// Yeni bir ev veya oda ilanı oluşturup sisteme ekleyen Use Case.
class AddListingUseCase {
  final ListingRepository repository;
  AddListingUseCase(this.repository);

  /// İlan nesnesini yerel veritabanına ekler.
  Future<void> execute(ListingEntity listing) => repository.addListing(listing);
}

/// Bir ilanın favori durumunu değiştiren (ekleyen veya kaldıran) Use Case.
class ToggleFavoriteUseCase {
  final ListingRepository repository;
  ToggleFavoriteUseCase(this.repository);

  /// İlan ID'sini favoriler kümesine ekler ya da çıkarır.
  Future<void> execute(String listingId) => repository.toggleFavorite(listingId);
}

/// Kullanıcının favorilerine eklediği tüm ilan ID'lerini getiren Use Case.
class GetFavoriteIdsUseCase {
  final ListingRepository repository;
  GetFavoriteIdsUseCase(this.repository);

  /// Favori ilan ID setini döner.
  Future<Set<String>> execute() => repository.getFavoriteIds();
}

/// Kullanıcının kendi ilanını yayına alma veya yayından kaldırma Use Case'i.
class ToggleListingActiveUseCase {
  final ListingRepository repository;
  ToggleListingActiveUseCase(this.repository);

  /// Belirtilen ilanın aktiflik durumunu tersine çevirir.
  Future<void> execute(String listingId) =>
      repository.toggleListingActive(listingId);
}
