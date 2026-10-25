import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository.dart';

// EVENTS
abstract class ListingEvent extends Equatable {
  const ListingEvent();
  @override
  List<Object?> get props => [];
}

class LoadListingsEvent extends ListingEvent {}

class SearchQueryChangedEvent extends ListingEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class ApplyFiltersEvent extends ListingEvent {
  final ListingFilterParams filters;
  const ApplyFiltersEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

class ResetFiltersEvent extends ListingEvent {}

class ToggleFavoriteEvent extends ListingEvent {
  final String listingId;
  const ToggleFavoriteEvent(this.listingId);
  @override
  List<Object?> get props => [listingId];
}

class CreateListingEvent extends ListingEvent {
  final ListingModel listing;
  const CreateListingEvent(this.listing);
  @override
  List<Object?> get props => [listing];
}

class DeleteListingEvent extends ListingEvent {
  final String listingId;
  const DeleteListingEvent(this.listingId);
  @override
  List<Object?> get props => [listingId];
}

// STATES
abstract class ListingState extends Equatable {
  const ListingState();
  @override
  List<Object?> get props => [];
}

class ListingInitial extends ListingState {}

class ListingLoading extends ListingState {}

class ListingLoaded extends ListingState {
  final List<ListingModel> allListings;
  final List<ListingModel> filteredListings;
  final List<ListingModel> favorites;
  final List<ListingModel> myListings;
  final String searchQuery;
  final ListingFilterParams filters;

  const ListingLoaded({
    required this.allListings,
    required this.filteredListings,
    required this.favorites,
    required this.myListings,
    this.searchQuery = '',
    this.filters = const ListingFilterParams(),
  });

  bool get hasActiveFilters => !filters.isEmpty || searchQuery.isNotEmpty;

  ListingLoaded copyWith({
    List<ListingModel>? allListings,
    List<ListingModel>? filteredListings,
    List<ListingModel>? favorites,
    List<ListingModel>? myListings,
    String? searchQuery,
    ListingFilterParams? filters,
  }) {
    return ListingLoaded(
      allListings: allListings ?? this.allListings,
      filteredListings: filteredListings ?? this.filteredListings,
      favorites: favorites ?? this.favorites,
      myListings: myListings ?? this.myListings,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [
    allListings,
    filteredListings,
    favorites,
    myListings,
    searchQuery,
    filters,
  ];
}

class ListingError extends ListingState {
  final String message;
  const ListingError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingRepository _repository;

  ListingBloc({ListingRepository? repository})
    : _repository = repository ?? ListingRepository(),
      super(ListingInitial()) {
    on<LoadListingsEvent>(_onLoadListings);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ResetFiltersEvent>(_onResetFilters);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CreateListingEvent>(_onCreateListing);
    on<DeleteListingEvent>(_onDeleteListing);
  }

  Future<void> _onLoadListings(
    LoadListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingLoading());
    try {
      await _repository.initSampleDataIfNeeded();
      final all = _repository.getAllListings();
      final favorites = _repository.getFavorites();
      final myListings = _repository.getMyListings();

      emit(
        ListingLoaded(
          allListings: all,
          filteredListings: all,
          favorites: favorites,
          myListings: myListings,
        ),
      );
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<ListingState> emit,
  ) {
    if (state is ListingLoaded) {
      final current = state as ListingLoaded;
      final filtered = _repository.searchAndFilter(
        query: event.query,
        filter: current.filters,
      );
      emit(
        current.copyWith(searchQuery: event.query, filteredListings: filtered),
      );
    }
  }

  void _onApplyFilters(ApplyFiltersEvent event, Emitter<ListingState> emit) {
    if (state is ListingLoaded) {
      final current = state as ListingLoaded;
      final filtered = _repository.searchAndFilter(
        query: current.searchQuery,
        filter: event.filters,
      );
      emit(
        current.copyWith(filters: event.filters, filteredListings: filtered),
      );
    }
  }

  void _onResetFilters(ResetFiltersEvent event, Emitter<ListingState> emit) {
    if (state is ListingLoaded) {
      final current = state as ListingLoaded;
      final filtered = _repository.searchAndFilter(
        query: '',
        filter: const ListingFilterParams(),
      );
      emit(
        current.copyWith(
          searchQuery: '',
          filters: const ListingFilterParams(),
          filteredListings: filtered,
        ),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ListingState> emit,
  ) async {
    if (state is ListingLoaded) {
      final current = state as ListingLoaded;
      await _repository.toggleFavorite(event.listingId);

      final all = _repository.getAllListings();
      final favorites = _repository.getFavorites();
      final myListings = _repository.getMyListings();
      final filtered = _repository.searchAndFilter(
        query: current.searchQuery,
        filter: current.filters,
      );

      emit(
        current.copyWith(
          allListings: all,
          filteredListings: filtered,
          favorites: favorites,
          myListings: myListings,
        ),
      );
    }
  }

  Future<void> _onCreateListing(
    CreateListingEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _repository.saveListing(event.listing);
      final all = _repository.getAllListings();
      final favorites = _repository.getFavorites();
      final myListings = _repository.getMyListings();

      if (state is ListingLoaded) {
        final current = state as ListingLoaded;
        final filtered = _repository.searchAndFilter(
          query: current.searchQuery,
          filter: current.filters,
        );
        emit(
          current.copyWith(
            allListings: all,
            filteredListings: filtered,
            favorites: favorites,
            myListings: myListings,
          ),
        );
      } else {
        emit(
          ListingLoaded(
            allListings: all,
            filteredListings: all,
            favorites: favorites,
            myListings: myListings,
          ),
        );
      }
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListingEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _repository.deleteListing(event.listingId);
      final all = _repository.getAllListings();
      final favorites = _repository.getFavorites();
      final myListings = _repository.getMyListings();

      if (state is ListingLoaded) {
        final current = state as ListingLoaded;
        final filtered = _repository.searchAndFilter(
          query: current.searchQuery,
          filter: current.filters,
        );
        emit(
          current.copyWith(
            allListings: all,
            filteredListings: filtered,
            favorites: favorites,
            myListings: myListings,
          ),
        );
      }
    } catch (e) {
      emit(ListingError(e.toString()));
    }
  }
}
