import '../../../domain/entities/rental_entity.dart';

/// Kiralama modülünün durum (State) temel soyut sınıfı.
abstract class RentalState {}

/// İlk durum; kiralama verileri henüz yüklenmemişken geçerlidir.
class RentalInitialState extends RentalState {}

/// Kiralama verileri okunurken veya işlem yapılırken gösterilen yüklenme durumu.
class RentalLoadingState extends RentalState {}

/// Kiralama verilerinin (Aktif konaklama ve Kiraya verilenler) yüklendiği durum.
class RentalLoadedState extends RentalState {
  /// Kullanıcının kiracı olarak şu anda kaldığı aktif konaklama (Kiralık Tutulanlar)
  final RentalEntity? activeStay;

  /// Kullanıcının ev sahibi olarak başkalarına kiraya verdiği evler/odalar (Kiraya Verilenler)
  final List<RentalEntity> myGivenRentals;

  /// İşlem başarıyla bittiğinde gösterilecek opsiyonel bildirim mesajı (SnackBar için)
  final String? successMessage;

  RentalLoadedState({
    this.activeStay,
    required this.myGivenRentals,
    this.successMessage,
  });

  /// Kullanıcının devam eden geçerli bir aktif konaklaması olup olmadığını denetler.
  bool get hasActiveStay => activeStay != null && !activeStay!.isCompleted;

  /// Durumun kopyasını üretip belirli alanları güncellemeye yarayan yardımcı metot.
  RentalLoadedState copyWith({
    RentalEntity? activeStay,
    bool clearActiveStay = false,
    List<RentalEntity>? myGivenRentals,
    String? successMessage,
  }) {
    return RentalLoadedState(
      activeStay: clearActiveStay ? null : (activeStay ?? this.activeStay),
      myGivenRentals: myGivenRentals ?? this.myGivenRentals,
      successMessage: successMessage,
    );
  }
}

/// Kiralama veya çıkış işlemi sırasında hata oluştuğunda yayılan durum.
class RentalErrorState extends RentalState {
  /// Hata açıklaması
  final String message;
  RentalErrorState(this.message);
}
