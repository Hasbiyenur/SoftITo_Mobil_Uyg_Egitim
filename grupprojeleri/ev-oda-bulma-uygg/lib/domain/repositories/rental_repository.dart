import '../entities/rental_entity.dart';

/// Kiralama, rezervasyon ve aktif konaklama süreçlerinin soyut sözleşmesi (Repository Interface).
abstract class RentalRepository {
  /// Yeni bir kiralama / rezervasyon kaydı oluşturur.
  Future<void> createRental(RentalEntity rental);

  /// Kullanıcının şu anda aktif olarak konakladığı kiralama kaydını getirir (varsa).
  Future<RentalEntity?> getMyActiveStay(String userId);

  /// Ev sahibi olarak kullanıcının kiraya verdiği tüm konaklama kayıtlarını listeler.
  Future<List<RentalEntity>> getMyGivenRentals(String hostId);

  /// Aktif konaklamayı sonlandırır (Check-out işlemi gerçekleştirir).
  Future<void> checkoutActiveStay(String rentalId);
}
