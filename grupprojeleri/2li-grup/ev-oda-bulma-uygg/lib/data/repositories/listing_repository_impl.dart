import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../models/listing_model.dart';

/// ListingRepository arayüzünün yerel Hive veritabanı ve yerel JSON varlıkları (assets/roommates.json) ile çalışan uygulaması.
class ListingRepositoryImpl implements ListingRepository {
  /// Kullanıcıların oluşturduğu ilanların saklandığı Hive kutusu
  static const String _listingsBoxName = 'user_listings_box';

  /// Kullanıcının favoriye aldığı ilan kimliklerinin saklandığı Hive kutusu
  static const String _favoritesBoxName = 'favorites_box';

  Box get _listingsBox => Hive.box(_listingsBoxName);
  Box get _favoritesBox => Hive.box(_favoritesBoxName);

  /// JSON dosyasından bir kez okunan örnek ilanların bellekte tutulan önbelleği
  List<ListingEntity>? _cachedAssetListings;

  /// Tüm ilanları getirir. Önce kullanıcı tarafından oluşturulan güncel ilanları,
  /// ardından yerel JSON dosyasındaki (assets/roommates.json) hazır ilanları birleştirir.
  @override
  Future<List<ListingEntity>> getAllListings() async {
    // 1. Örnek ilanlar bellekte yoksa assets/roommates.json dosyasından oku
    if (_cachedAssetListings == null) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/roommates.json');
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        _cachedAssetListings = jsonList
            .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _cachedAssetListings = [];
      }
    }

    // 2. Kullanıcının Hive kutusuna eklediği özel ilanları çek
    final List<ListingEntity> userListings = [];
    for (var key in _listingsBox.keys) {
      final String? itemJson = _listingsBox.get(key) as String?;
      if (itemJson != null) {
        try {
          final map = jsonDecode(itemJson) as Map<String, dynamic>;
          userListings.add(ListingModel.fromJson(map));
        } catch (_) {}
      }
    }

    // Kullanıcı ilanları listenin başında (en yeni olarak) görünecek şekilde birleştirilir
    return [...userListings, ...(_cachedAssetListings ?? [])];
  }

  /// Yeni bir ilanı Hive kutusuna JSON formatında kaydeder.
  @override
  Future<void> addListing(ListingEntity listing) async {
    final model = ListingModel.fromEntity(listing);
    final jsonStr = jsonEncode(model.toJson());
    await _listingsBox.put(listing.id, jsonStr);
  }

  /// Favoriye eklenmiş ilanların kimliklerini (ID) döner.
  @override
  Future<Set<String>> getFavoriteIds() async {
    final List<dynamic>? list = _favoritesBox.get('favorite_ids') as List<dynamic>?;
    if (list == null) return {};
    return list.map((e) => e.toString()).toSet();
  }

  /// Belirtilen ilanın favori durumunu tersine çevirir (varsa çıkartır, yoksa listeye ekler).
  @override
  Future<void> toggleFavorite(String listingId) async {
    final currentFavorites = await getFavoriteIds();
    final updated = Set<String>.from(currentFavorites);
    if (updated.contains(listingId)) {
      updated.remove(listingId);
    } else {
      updated.add(listingId);
    }
    await _favoritesBox.put('favorite_ids', updated.toList());
  }

  /// Belirli bir kullanıcıya ait (veya kullanıcının oluşturduğu) ilanları filtreler.
  @override
  Future<List<ListingEntity>> getUserListings(String userId) async {
    final all = await getAllListings();
    return all.where((l) => l.owner.id == userId || l.isUserCreated).toList();
  }

  /// Kullanıcının kendi ilanını aktif veya pasif hale getirmesini sağlar.
  @override
  Future<void> toggleListingActive(String listingId) async {
    final String? itemJson = _listingsBox.get(listingId) as String?;
    if (itemJson != null) {
      final map = jsonDecode(itemJson) as Map<String, dynamic>;
      final currentActive = map['isActive'] as bool? ?? true;
      map['isActive'] = !currentActive;
      await _listingsBox.put(listingId, jsonEncode(map));
    }
  }
}
