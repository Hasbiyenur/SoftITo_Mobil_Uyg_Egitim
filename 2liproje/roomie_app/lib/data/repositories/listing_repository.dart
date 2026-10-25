import 'dart:convert';

import 'package:flutter/services.dart';

import '../datasources/hive_storage_service.dart';
import '../models/listing_model.dart';

class ListingFilterParams {
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final String? district;
  final bool? petFriendly;
  final bool? smokingAllowed;
  final String? sleepHabit;
  final String? cleanliness;
  final String? language;

  const ListingFilterParams({
    this.minPrice,
    this.maxPrice,
    this.city,
    this.district,
    this.petFriendly,
    this.smokingAllowed,
    this.sleepHabit,
    this.cleanliness,
    this.language,
  });

  bool get isEmpty =>
      minPrice == null &&
      maxPrice == null &&
      (city == null || city == 'Tümü') &&
      (district == null || district == 'Tümü') &&
      petFriendly == null &&
      smokingAllowed == null &&
      (sleepHabit == null || sleepHabit == 'Tümü') &&
      (cleanliness == null || cleanliness == 'Tümü') &&
      (language == null || language == 'Tümü');
}

class ListingRepository {
  final HiveStorageService _storage;
  static const String _seededKey = 'is_listings_seeded_v1';

  ListingRepository({HiveStorageService? storage})
    : _storage = storage ?? HiveStorageService.instance;

  /// Loads initial sample listings from assets/roommates.json ONLY on first startup.
  /// Preserves user edits, deletions, and additions across restarts.
  Future<void> initSampleDataIfNeeded() async {
    final isSeeded =
        _storage.settingsBox.get(_seededKey, defaultValue: false) as bool;
    if (isSeeded && _storage.listingsBox.isNotEmpty) {
      return;
    }

    try {
      final jsonString = await rootBundle
          .loadString('assets/roommates.json')
          .timeout(const Duration(milliseconds: 500));
      final dynamic decoded = json.decode(jsonString);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            final model = ListingModel.fromMap(
              Map<dynamic, dynamic>.from(item),
            );
            await _storage.listingsBox.put(model.id, model.toMap());
          }
        }
        await _storage.settingsBox.put(_seededKey, true);
      }
    } catch (e) {
      // Fallback if asset loading fails in headless tests
    }
  }

  List<ListingModel> getAllListings() {
    final favorites = getFavoriteIds();
    final List<ListingModel> list = [];

    for (var key in _storage.listingsBox.keys) {
      final data = _storage.listingsBox.get(key);
      if (data is Map) {
        final model = ListingModel.fromMap(Map<dynamic, dynamic>.from(data));
        list.add(model.copyWith(isFavorite: favorites.contains(model.id)));
      }
    }

    // Sort newest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  ListingModel? getListingById(String id) {
    final data = _storage.listingsBox.get(id);
    if (data is Map) {
      final favorites = getFavoriteIds();
      final model = ListingModel.fromMap(Map<dynamic, dynamic>.from(data));
      return model.copyWith(isFavorite: favorites.contains(model.id));
    }
    return null;
  }

  List<ListingModel> searchAndFilter({
    String query = '',
    ListingFilterParams? filter,
  }) {
    final all = getAllListings();
    final trimmedQuery = query.trim().toLowerCase();

    return all.where((item) {
      // Search query filter (title, description, city, district)
      if (trimmedQuery.isNotEmpty) {
        final matchTitle = item.title.toLowerCase().contains(trimmedQuery);
        final matchDesc = item.description.toLowerCase().contains(trimmedQuery);
        final matchCity = item.city.toLowerCase().contains(trimmedQuery);
        final matchDist = item.district.toLowerCase().contains(trimmedQuery);
        if (!matchTitle && !matchDesc && !matchCity && !matchDist) {
          return false;
        }
      }

      if (filter == null || filter.isEmpty) {
        return true;
      }

      // Price filter
      if (filter.minPrice != null && item.monthlyPrice < filter.minPrice!) {
        return false;
      }
      if (filter.maxPrice != null && item.monthlyPrice > filter.maxPrice!) {
        return false;
      }

      // Location filter
      if (filter.city != null &&
          filter.city != 'Tümü' &&
          item.city != filter.city) {
        return false;
      }
      if (filter.district != null &&
          filter.district != 'Tümü' &&
          item.district != filter.district) {
        return false;
      }

      // Habits & Preferences
      if (filter.petFriendly != null &&
          item.preferences.petFriendly != filter.petFriendly) {
        return false;
      }
      if (filter.smokingAllowed != null &&
          item.preferences.smokingAllowed != filter.smokingAllowed) {
        return false;
      }
      if (filter.sleepHabit != null &&
          filter.sleepHabit != 'Tümü' &&
          item.preferences.sleepHabit != filter.sleepHabit) {
        return false;
      }
      if (filter.cleanliness != null &&
          filter.cleanliness != 'Tümü' &&
          item.preferences.cleanliness != filter.cleanliness) {
        return false;
      }
      if (filter.language != null && filter.language != 'Tümü') {
        if (!item.preferences.languages.contains(filter.language)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> saveListing(ListingModel listing) async {
    await _storage.listingsBox.put(listing.id, listing.toMap());
  }

  Future<void> updateListingStatus(String id, String status) async {
    final listing = getListingById(id);
    if (listing != null) {
      final updated = listing.copyWith(status: status);
      await saveListing(updated);
    }
  }

  Future<void> deleteListing(String id) async {
    await _storage.listingsBox.delete(id);
    await _storage.favoritesBox.delete(id);
  }

  // Favorites
  Set<String> getFavoriteIds() {
    return _storage.favoritesBox.keys.map((e) => e.toString()).toSet();
  }

  List<ListingModel> getFavorites() {
    final favIds = getFavoriteIds();
    final all = getAllListings();
    return all.where((l) => favIds.contains(l.id)).toList();
  }

  Future<bool> toggleFavorite(String listingId) async {
    final exists = _storage.favoritesBox.containsKey(listingId);
    if (exists) {
      await _storage.favoritesBox.delete(listingId);
      return false;
    } else {
      await _storage.favoritesBox.put(listingId, true);
      return true;
    }
  }

  List<ListingModel> getMyListings() {
    final all = getAllListings();
    return all.where((l) => l.isMyListing).toList();
  }
}
