import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/listing_entity.dart';
import '../../../domain/usecases/listing_usecases.dart';
import 'listing_event.dart';
import 'listing_state.dart';

/// İlanların yüklenmesi, metin araması, çok kriterli filtrelenmesi, favorilere eklenmesi
/// ve yeni ilan oluşturulmasını yöneten BLoC sınıfı.
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final GetAllListingsUseCase getAllListingsUseCase;
  final AddListingUseCase addListingUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetFavoriteIdsUseCase getFavoriteIdsUseCase;
  final ToggleListingActiveUseCase toggleListingActiveUseCase;

  ListingBloc({
    required this.getAllListingsUseCase,
    required this.addListingUseCase,
    required this.toggleFavoriteUseCase,
    required this.getFavoriteIdsUseCase,
    required this.toggleListingActiveUseCase,
  }) : super(ListingInitialState()) {
    on<LoadListingsEvent>(_onLoadListings);
    on<SearchListingsEvent>(_onSearchListings);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<ClearFilterEvent>(_onClearFilter);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<AddNewListingEvent>(_onAddNewListing);
    on<ToggleListingActiveEvent>(_onToggleListingActive);
  }

  /// Tüm ilanları ve favori ID'leri eşzamanlı olarak çeker ve arayüze sunar.
  Future<void> _onLoadListings(
      LoadListingsEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoadingState());
    try {
      final listings = await getAllListingsUseCase.execute();
      final favorites = await getFavoriteIdsUseCase.execute();
      emit(ListingLoadedState(
        allListings: listings,
        filteredListings: listings,
        favoriteIds: favorites,
      ));
    } catch (e) {
      emit(ListingErrorState(e.toString()));
    }
  }

  /// Arama kutusuna yazılan metne göre anlık olarak ilanları filtreler.
  void _onSearchListings(
      SearchListingsEvent event, Emitter<ListingState> emit) {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      final query = event.query.toLowerCase().trim();
      final filtered = _filterList(current.allListings, query, current.filters);
      emit(current.copyWith(searchQuery: event.query, filteredListings: filtered));
    }
  }

  /// Gelişmiş filtreleme kriterlerini (fiyat, şehir, sigara, evcil hayvan vb.) uygular.
  void _onApplyFilter(ApplyFilterEvent event, Emitter<ListingState> emit) {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      final filtered = _filterList(
          current.allListings, current.searchQuery.toLowerCase().trim(), event.filters);
      emit(current.copyWith(filters: event.filters, filteredListings: filtered));
    }
  }

  /// Uygulanmış olan tüm filtreleri kaldırır ve listeyi varsayılana döndürür.
  void _onClearFilter(ClearFilterEvent event, Emitter<ListingState> emit) {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      const emptyFilters = ListingFilterCriteria();
      final filtered = _filterList(
          current.allListings, current.searchQuery.toLowerCase().trim(), emptyFilters);
      emit(current.copyWith(filters: emptyFilters, filteredListings: filtered));
    }
  }

  /// İlanın favori durumunu tersine çevirir ve durumu günceller.
  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<ListingState> emit) async {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      await toggleFavoriteUseCase.execute(event.listingId);
      final updatedFavorites = Set<String>.from(current.favoriteIds);
      if (updatedFavorites.contains(event.listingId)) {
        updatedFavorites.remove(event.listingId);
      } else {
        updatedFavorites.add(event.listingId);
      }
      emit(current.copyWith(favoriteIds: updatedFavorites));
    }
  }

  /// Kullanıcı yeni bir ilan eklediğinde listeye ekler ve filtreyi yeniden hesaplar.
  Future<void> _onAddNewListing(
      AddNewListingEvent event, Emitter<ListingState> emit) async {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      await addListingUseCase.execute(event.listing);
      final updatedList = [event.listing, ...current.allListings];
      final filtered = _filterList(
        updatedList,
        current.searchQuery.toLowerCase().trim(),
        current.filters,
      );
      emit(current.copyWith(allListings: updatedList, filteredListings: filtered));
    }
  }

  /// Kullanıcının kendi ilanının aktiflik (yayında/pasif) durumunu değiştirir.
  Future<void> _onToggleListingActive(
      ToggleListingActiveEvent event, Emitter<ListingState> emit) async {
    if (state is ListingLoadedState) {
      final current = state as ListingLoadedState;
      await toggleListingActiveUseCase.execute(event.listingId);
      final updatedList = current.allListings.map((l) {
        if (l.id == event.listingId) {
          return l.copyWith(isActive: !l.isActive);
        }
        return l;
      }).toList();
      final filtered = _filterList(
        updatedList,
        current.searchQuery.toLowerCase().trim(),
        current.filters,
      );
      emit(current.copyWith(allListings: updatedList, filteredListings: filtered));
    }
  }

  /// Arama sorgusu ve filtre kriterlerine göre ilan listesini süzen yardımcı fonksiyon.
  List<ListingEntity> _filterList(
    List<ListingEntity> list,
    String query,
    ListingFilterCriteria filters,
  ) {
    return list.where((item) {
      // 1. Metin araması: Başlık, açıklama, şehir veya ilçe ile eşleşme
      if (query.isNotEmpty) {
        final titleMatch = item.title.toLowerCase().contains(query);
        final descMatch = item.description.toLowerCase().contains(query);
        final cityMatch = item.city.toLowerCase().contains(query);
        final districtMatch = item.district.toLowerCase().contains(query);
        if (!titleMatch && !descMatch && !cityMatch && !districtMatch) {
          return false;
        }
      }

      // 2. Minimum ve Maksimum Kira Fiyatı Kontrolü
      if (filters.minPrice != null && item.monthlyRent < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && item.monthlyRent > filters.maxPrice!) {
        return false;
      }

      // 3. Şehir Eşleşmesi
      if (filters.city != null && filters.city!.isNotEmpty) {
        if (item.city.toLowerCase() != filters.city!.toLowerCase()) {
          return false;
        }
      }

      // 4. Evcil Hayvan Dostu Olma Kriteri
      if (filters.petAllowed != null &&
          item.preferences.petAllowed != filters.petAllowed) {
        return false;
      }

      // 5. Sigara Kullanımı Kriteri
      if (filters.smokingAllowed != null &&
          item.preferences.smokingAllowed != filters.smokingAllowed) {
        return false;
      }

      // 6. Uyku Düzeni Kriteri
      if (filters.sleepSchedule != null &&
          filters.sleepSchedule != 'farketmez' &&
          item.preferences.sleepSchedule != 'farketmez' &&
          item.preferences.sleepSchedule != filters.sleepSchedule) {
        return false;
      }

      // 7. Temizlik Hassasiyeti Kriteri
      if (filters.cleaningSensitivity != null &&
          filters.cleaningSensitivity != 'hepsi' &&
          item.preferences.cleaningSensitivity != filters.cleaningSensitivity) {
        return false;
      }

      // 8. Dil Uyumu Kriteri
      if (filters.language != null && filters.language!.isNotEmpty) {
        if (!item.preferences.languages.contains(filters.language)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
