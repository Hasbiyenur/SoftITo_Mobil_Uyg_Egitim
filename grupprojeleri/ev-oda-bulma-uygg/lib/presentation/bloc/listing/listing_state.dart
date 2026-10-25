import '../../../domain/entities/listing_entity.dart';
import 'listing_event.dart';

/// İlan ekranlarının durum (State) temel soyut sınıfı.
abstract class ListingState {}

/// İlk durum; ilanlar henüz yüklenmemişken geçerlidir.
class ListingInitialState extends ListingState {}

/// İlanlar yüklenirken gösterilen yükleme durumu.
class ListingLoadingState extends ListingState {}

/// İlanların başarıyla yüklendiği ve arama/filtreleme sonuçlarıyla görüntülendiği ana durum.
class ListingLoadedState extends ListingState {
  /// Sistemdeki tüm ilanların ham listesi
  final List<ListingEntity> allListings;

  /// Arama ve filtre kriterlerine uyan filtrelenmiş ilanlar listesi
  final List<ListingEntity> filteredListings;

  /// Kullanıcının favoriye eklediği ilan ID'lerinin kümesi
  final Set<String> favoriteIds;

  /// Şu anda aktif olan arama sorgusu
  final String searchQuery;

  /// Şu anda uygulanan filtreleme kriterleri
  final ListingFilterCriteria filters;

  ListingLoadedState({
    required this.allListings,
    required this.filteredListings,
    required this.favoriteIds,
    this.searchQuery = '',
    this.filters = const ListingFilterCriteria(),
  });

  /// Kullanıcının favori ilanlarını dinamik olarak listeler.
  List<ListingEntity> get favoriteListings =>
      allListings.where((item) => favoriteIds.contains(item.id)).toList();

  /// Mevcut durumun belirli alanlarını güncelleyerek yeni durum nesnesi oluşturur.
  ListingLoadedState copyWith({
    List<ListingEntity>? allListings,
    List<ListingEntity>? filteredListings,
    Set<String>? favoriteIds,
    String? searchQuery,
    ListingFilterCriteria? filters,
  }) {
    return ListingLoadedState(
      allListings: allListings ?? this.allListings,
      filteredListings: filteredListings ?? this.filteredListings,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }
}

/// İlan yükleme veya kaydetme sırasında bir hata oluştuğunda yayılan durum.
class ListingErrorState extends ListingState {
  /// Kullanıcıya gösterilecek hata mesajı
  final String message;
  ListingErrorState(this.message);
}
