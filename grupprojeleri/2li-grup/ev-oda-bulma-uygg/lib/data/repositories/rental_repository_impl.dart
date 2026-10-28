import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/rental_entity.dart';
import '../../domain/repositories/rental_repository.dart';
import '../models/rental_model.dart';

/// RentalRepository arayüzünün Hive yerel veritabanı ile çalışan uygulaması.
/// Rezervasyon oluşturma, aktif konaklama sorgulama ve çıkış (checkout) işlemlerini yürütür.
class RentalRepositoryImpl implements RentalRepository {
  /// Kiralama kayıtlarının tutulduğu Hive kutusu
  static const String _boxName = 'rentals_box';

  Box get _box => Hive.box(_boxName);

  /// Yeni bir kiralama / rezervasyon kaydını JSON olarak saklar.
  @override
  Future<void> createRental(RentalEntity rental) async {
    final model = RentalModel.fromEntity(rental);
    await _box.put(rental.id, jsonEncode(model.toJson()));
  }

  /// Belirtilen kullanıcının şu anda devam eden (check-out yapılmamış) aktif konaklamasını döner.
  @override
  Future<RentalEntity?> getMyActiveStay(String userId) async {
    // Eski veya geçersiz örnek kayıtları temizle
    _box.delete('rental-sample-1');
    _box.delete('rental-sample-2');

    final List<RentalModel> activeList = [];
    for (var key in _box.keys) {
      final String? itemJson = _box.get(key) as String?;
      if (itemJson != null) {
        try {
          final map = jsonDecode(itemJson) as Map<String, dynamic>;
          final model = RentalModel.fromJson(map);
          // Giriş yapan kullanıcının kiracı olduğu ve tamamlanmamış konaklamaları topla
          if (model.tenantId == userId && !model.isCompleted) {
            activeList.add(model);
          }
        } catch (_) {}
      }
    }
    if (activeList.isEmpty) return null;
    // En son yapılan rezervasyonu ilk sıraya al
    activeList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activeList.first;
  }

  /// Belirtilen ev sahibinin ilanları üzerinden yapılan tüm kiralamaları listeler.
  @override
  Future<List<RentalEntity>> getMyGivenRentals(String hostId) async {
    final List<RentalEntity> list = [];
    for (var key in _box.keys) {
      final String? itemJson = _box.get(key) as String?;
      if (itemJson != null) {
        try {
          final map = jsonDecode(itemJson) as Map<String, dynamic>;
          final model = RentalModel.fromJson(map);
          if (model.hostId == hostId) {
            list.add(model);
          }
        } catch (_) {}
      }
    }
    return list;
  }

  /// Aktif konaklamayı sonlandırır (isCompleted değerini true yapar).
  @override
  Future<void> checkoutActiveStay(String rentalId) async {
    final String? itemJson = _box.get(rentalId) as String?;
    if (itemJson != null) {
      final map = jsonDecode(itemJson) as Map<String, dynamic>;
      map['isCompleted'] = true;
      await _box.put(rentalId, jsonEncode(map));
    }
  }
}
