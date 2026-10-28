import '../../../domain/entities/listing_entity.dart';

/// İlan filtreleme seçeneklerini (fiyat aralığı, şehir, alışkanlıklar) bir arada tutan yardımcı kriter sınıfı.
class ListingFilterCriteria {
  /// Minimum aylık kira tutarı
  final double? minPrice;

  /// Maksimum aylık kira tutarı
  final double? maxPrice;

  /// Filtrelenecek şehir (Örn: 'İstanbul')
  final String? city;

  /// Evcil hayvan izni filtresi (true: sadece izin verenler)
  final bool? petAllowed;

  /// Sigara kullanım izni filtresi (true: sadece izin verenler)
  final bool? smokingAllowed;

  /// İstenen uyku düzeni (Örn: 'gece', 'sabah', 'farketmez')
  final String? sleepSchedule;

  /// İstenen temizlik seviyesi (Örn: 'yok', 'az', 'orta', 'çok')
  final String? cleaningSensitivity;

  /// Konuşulan yabancı dil / ortak dil
  final String? language;

  const ListingFilterCriteria({
    this.minPrice,
    this.maxPrice,
    this.city,
    this.petAllowed,
    this.smokingAllowed,
    this.sleepSchedule,
    this.cleaningSensitivity,
    this.language,
  });

  /// Kullanıcının herhangi bir aktif filtre seçip seçmediğini denetler.
  bool get isActive =>
      minPrice != null ||
      maxPrice != null ||
      (city != null && city!.isNotEmpty) ||
      petAllowed != null ||
      smokingAllowed != null ||
      (sleepSchedule != null && sleepSchedule != 'farketmez') ||
      (cleaningSensitivity != null && cleaningSensitivity != 'hepsi') ||
      (language != null && language!.isNotEmpty);
}

/// İlanlar ile ilgili kullanıcı ve sistem eylemlerinin temel soyut sınıfı.
abstract class ListingEvent {}

/// Tüm ilanları ve favorileri veritabanından yüklemek için tetiklenen olay.
class LoadListingsEvent extends ListingEvent {}

/// Arama çubuğuna girilen metne göre ilanları filtreleyen olay.
class SearchListingsEvent extends ListingEvent {
  /// Kullanıcının yazdığı arama kelimesi
  final String query;
  SearchListingsEvent(this.query);
}

/// Alt panelden (BottomSheet) seçilen filtre kriterlerini uygulayan olay.
class ApplyFilterEvent extends ListingEvent {
  final ListingFilterCriteria filters;
  ApplyFilterEvent(this.filters);
}

/// Uygulanmış olan tüm filtreleri sıfırlayan olay.
class ClearFilterEvent extends ListingEvent {}

/// İlanı favorilere ekleyen veya favorilerden çıkaran olay.
class ToggleFavoriteEvent extends ListingEvent {
  final String listingId;
  ToggleFavoriteEvent(this.listingId);
}

/// Kullanıcının yeni bir ev veya oda ilanı eklemesi olayı.
class AddNewListingEvent extends ListingEvent {
  final ListingEntity listing;
  AddNewListingEvent(this.listing);
}

/// Kullanıcının kendi ilanını yayına alma veya yayından kaldırma (aktif/pasif) olayı.
class ToggleListingActiveEvent extends ListingEvent {
  final String listingId;
  ToggleListingActiveEvent(this.listingId);
}
