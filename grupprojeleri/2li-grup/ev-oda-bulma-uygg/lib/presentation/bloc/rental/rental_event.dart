import '../../../domain/entities/rental_entity.dart';

/// Kiralama ve konaklama süreçlerinde tetiklenen olayların (Events) temel soyut sınıfı.
abstract class RentalEvent {}

/// Kullanıcının aktif konaklamasını ve kiraya verdiği evleri yükleme olayı.
class LoadRentalsEvent extends RentalEvent {
  /// Giriş yapan kullanıcının kimlik numarası
  final String userId;
  LoadRentalsEvent(this.userId);
}

/// Yeni bir kiralama / rezervasyon oluşturulduğunda tetiklenen olay.
class CreateRentalBookingEvent extends RentalEvent {
  /// Oluşturulan kiralama varlığı
  final RentalEntity rental;
  CreateRentalBookingEvent(this.rental);
}

/// Aktif konaklanan evden çıkış (Check-out) yapıldığında tetiklenen olay.
class CheckoutActiveRentalEvent extends RentalEvent {
  /// Çıkış yapılacak kiralama kaydının ID'si
  final String rentalId;

  /// İşlemi yapan kullanıcının kimliği
  final String userId;

  CheckoutActiveRentalEvent({required this.rentalId, required this.userId});
}
