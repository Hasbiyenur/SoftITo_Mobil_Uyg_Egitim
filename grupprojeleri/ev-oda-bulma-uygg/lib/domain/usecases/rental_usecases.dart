import '../entities/rental_entity.dart';
import '../repositories/rental_repository.dart';

/// Yeni bir kiralama / rezervasyon işlemi başlatan Use Case.
class CreateRentalUseCase {
  final RentalRepository repository;
  CreateRentalUseCase(this.repository);

  /// Rezervasyon kaydını doğrular ve veritabanına ekler.
  Future<void> execute(RentalEntity rental) => repository.createRental(rental);
}

/// Giriş yapan kullanıcının devam eden aktif konaklamasını getiren Use Case.
class GetMyActiveStayUseCase {
  final RentalRepository repository;
  GetMyActiveStayUseCase(this.repository);

  /// Kullanıcı ID'sine göre aktif kalınan evi döner (varsa).
  Future<RentalEntity?> execute(String userId) =>
      repository.getMyActiveStay(userId);
}

/// Ev sahibi olarak kiraya verilen tüm konaklamaları getiren Use Case.
class GetMyGivenRentalsUseCase {
  final RentalRepository repository;
  GetMyGivenRentalsUseCase(this.repository);

  /// Ev sahibinin ilanlarına ait tüm kiralamaları listeler.
  Future<List<RentalEntity>> execute(String hostId) =>
      repository.getMyGivenRentals(hostId);
}

/// Aktif konaklamayı sonlandırıp check-out yapan Use Case.
class CheckoutActiveStayUseCase {
  final RentalRepository repository;
  CheckoutActiveStayUseCase(this.repository);

  /// Kiralama ID'sine göre konaklamayı tamamlandı olarak işaretler.
  Future<void> execute(String rentalId) =>
      repository.checkoutActiveStay(rentalId);
}
