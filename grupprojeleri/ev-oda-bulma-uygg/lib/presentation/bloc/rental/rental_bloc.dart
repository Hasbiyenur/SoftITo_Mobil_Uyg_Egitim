import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/rental_usecases.dart';
import 'rental_event.dart';
import 'rental_state.dart';

/// Ev/Oda kiralama, rezervasyon takibi, check-out ve ev sahibi kiralamalarını yöneten BLoC sınıfı.
class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final CreateRentalUseCase createRentalUseCase;
  final GetMyActiveStayUseCase getMyActiveStayUseCase;
  final GetMyGivenRentalsUseCase getMyGivenRentalsUseCase;
  final CheckoutActiveStayUseCase checkoutActiveStayUseCase;

  RentalBloc({
    required this.createRentalUseCase,
    required this.getMyActiveStayUseCase,
    required this.getMyGivenRentalsUseCase,
    required this.checkoutActiveStayUseCase,
  }) : super(RentalInitialState()) {
    on<LoadRentalsEvent>(_onLoadRentals);
    on<CreateRentalBookingEvent>(_onCreateRentalBooking);
    on<CheckoutActiveRentalEvent>(_onCheckoutActiveRental);
  }

  /// Kullanıcının aktif konaklamasını ve kiraya verdiği evleri yükler.
  Future<void> _onLoadRentals(
      LoadRentalsEvent event, Emitter<RentalState> emit) async {
    emit(RentalLoadingState());
    try {
      final activeStay = await getMyActiveStayUseCase.execute(event.userId);
      final myGivenRentals =
          await getMyGivenRentalsUseCase.execute(event.userId);
      emit(RentalLoadedState(
        activeStay: activeStay,
        myGivenRentals: myGivenRentals,
      ));
    } catch (e) {
      emit(RentalErrorState(e.toString()));
    }
  }

  /// Yeni bir kiralama rezervasyonu oluşturur ve verileri günceller.
  Future<void> _onCreateRentalBooking(
      CreateRentalBookingEvent event, Emitter<RentalState> emit) async {
    try {
      await createRentalUseCase.execute(event.rental);
      final activeStay =
          await getMyActiveStayUseCase.execute(event.rental.tenantId);
      final myGivenRentals =
          await getMyGivenRentalsUseCase.execute(event.rental.tenantId);

      emit(RentalLoadedState(
        activeStay: activeStay,
        myGivenRentals: myGivenRentals,
        successMessage: 'Kiralama işleminiz başarıyla tamamlandı!',
      ));
    } catch (e) {
      emit(RentalErrorState(e.toString()));
    }
  }

  /// Aktif konaklamadan çıkış (Check-out) işlemini gerçekleştirir.
  Future<void> _onCheckoutActiveRental(
      CheckoutActiveRentalEvent event, Emitter<RentalState> emit) async {
    try {
      await checkoutActiveStayUseCase.execute(event.rentalId);
      final activeStay = await getMyActiveStayUseCase.execute(event.userId);
      final myGivenRentals =
          await getMyGivenRentalsUseCase.execute(event.userId);

      emit(RentalLoadedState(
        activeStay: activeStay,
        myGivenRentals: myGivenRentals,
        successMessage: 'Evden/Odadan başarıyla çıkış yapıldı.',
      ));
    } catch (e) {
      emit(RentalErrorState(e.toString()));
    }
  }
}
