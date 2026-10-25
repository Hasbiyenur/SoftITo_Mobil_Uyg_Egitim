import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/failures.dart';
import '../../data/models/rental_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/rental_repository.dart';

// EVENTS
abstract class RentalEvent extends Equatable {
  const RentalEvent();
  @override
  List<Object?> get props => [];
}

class LoadRentalsEvent extends RentalEvent {
  final String? tenantId;
  const LoadRentalsEvent([this.tenantId]);
  @override
  List<Object?> get props => [tenantId];
}

class ClearRentalsEvent extends RentalEvent {
  const ClearRentalsEvent();
}

class BookRentalEvent extends RentalEvent {
  final RentalModel rental;
  const BookRentalEvent(this.rental);
  @override
  List<Object?> get props => [rental];
}

class CompleteEarlyCheckoutEvent extends RentalEvent {
  final String rentalId;
  final String checkoutPhotoPath;
  final DateTime? exitTime;
  const CompleteEarlyCheckoutEvent({
    required this.rentalId,
    required this.checkoutPhotoPath,
    this.exitTime,
  });
  @override
  List<Object?> get props => [rentalId, checkoutPhotoPath, exitTime];
}

class RequestEarlyExitTenantEvent extends RentalEvent {
  final String tenantId;
  final String tenantName;
  final String? tenantAvatar;
  final String listingTitle;
  final UserModel currentUser;

  const RequestEarlyExitTenantEvent({
    required this.tenantId,
    required this.tenantName,
    this.tenantAvatar,
    required this.listingTitle,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [
    tenantId,
    tenantName,
    tenantAvatar,
    listingTitle,
    currentUser,
  ];
}

// STATES
abstract class RentalState extends Equatable {
  const RentalState();
  @override
  List<Object?> get props => [];
}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalLoaded extends RentalState {
  final RentalModel? activeRental;
  final List<RentalModel> rentalHistory;
  final List<RentalModel> allRentals;

  const RentalLoaded({
    this.activeRental,
    this.rentalHistory = const [],
    this.allRentals = const [],
  });

  bool get hasActiveRental => activeRental != null && activeRental!.isActive;

  RentalLoaded copyWith({
    RentalModel? activeRental,
    bool clearActiveRental = false,
    List<RentalModel>? rentalHistory,
    List<RentalModel>? allRentals,
  }) {
    return RentalLoaded(
      activeRental: clearActiveRental
          ? null
          : (activeRental ?? this.activeRental),
      rentalHistory: rentalHistory ?? this.rentalHistory,
      allRentals: allRentals ?? this.allRentals,
    );
  }

  @override
  List<Object?> get props => [activeRental, rentalHistory, allRentals];
}

class RentalActionSuccess extends RentalState {
  final String message;
  final EarlyCheckoutResult? checkoutResult;
  const RentalActionSuccess(this.message, {this.checkoutResult});
  @override
  List<Object?> get props => [message, checkoutResult];
}

class RentalActionError extends RentalState {
  final String message;
  const RentalActionError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final RentalRepository _rentalRepository;
  final ChatRepository _chatRepository;

  String? _currentTenantId;

  RentalBloc({
    RentalRepository? rentalRepository,
    ChatRepository? chatRepository,
  }) : _rentalRepository = rentalRepository ?? RentalRepository(),
       _chatRepository = chatRepository ?? ChatRepository(),
       super(RentalInitial()) {
    on<LoadRentalsEvent>(_onLoadRentals);
    on<ClearRentalsEvent>(_onClearRentals);
    on<BookRentalEvent>(_onBookRental);
    on<CompleteEarlyCheckoutEvent>(_onCompleteEarlyCheckout);
    on<RequestEarlyExitTenantEvent>(_onRequestEarlyExitTenant);
  }

  void _onLoadRentals(LoadRentalsEvent event, Emitter<RentalState> emit) {
    emit(RentalLoading());
    try {
      final tenantId = event.tenantId ?? _currentTenantId;
      _currentTenantId = tenantId;
      final active = _rentalRepository.getActiveRental(tenantId: tenantId);
      final history = _rentalRepository.getRentalHistory(tenantId: tenantId);
      final all = _rentalRepository.getAllRentals();

      emit(
        RentalLoaded(
          activeRental: active,
          rentalHistory: history,
          allRentals: all,
        ),
      );
    } catch (e) {
      emit(RentalActionError(e.toString()));
    }
  }

  void _onClearRentals(ClearRentalsEvent event, Emitter<RentalState> emit) {
    _currentTenantId = null;
    emit(const RentalLoaded(activeRental: null, rentalHistory: [], allRentals: []));
  }

  Future<void> _onBookRental(
    BookRentalEvent event,
    Emitter<RentalState> emit,
  ) async {
    try {
      _currentTenantId = event.rental.tenantId;
      await _rentalRepository.bookRental(event.rental);
      final active = _rentalRepository.getActiveRental(tenantId: event.rental.tenantId);
      final history = _rentalRepository.getRentalHistory(tenantId: event.rental.tenantId);
      final all = _rentalRepository.getAllRentals();

      emit(
        const RentalActionSuccess(
          'Rezervasyonunuz ve demo ödemeniz başarıyla tamamlandı!',
        ),
      );
      emit(
        RentalLoaded(
          activeRental: active,
          rentalHistory: history,
          allRentals: all,
        ),
      );
    } on Failure catch (f) {
      emit(RentalActionError(f.message));
      _reloadState(emit);
    } catch (e) {
      emit(RentalActionError(e.toString().replaceAll('Exception: ', '')));
      _reloadState(emit);
    }
  }

  Future<void> _onCompleteEarlyCheckout(
    CompleteEarlyCheckoutEvent event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final result = await _rentalRepository.completeEarlyCheckout(
        rentalId: event.rentalId,
        checkoutPhotoPath: event.checkoutPhotoPath,
        exitTime: event.exitTime,
      );

      _currentTenantId = result.completedRental.tenantId;
      final history =
          _rentalRepository.getRentalHistory(tenantId: _currentTenantId);
      final all = _rentalRepository.getAllRentals();

      emit(
        RentalActionSuccess(
          'Çıkış işleminiz onaylandı! ${result.daysStayed} gün kalış hesaplandı, kalan ${result.refundAmount.toStringAsFixed(0)} ₺ hesabınıza iade edildi.',
          checkoutResult: result,
        ),
      );
      emit(
        RentalLoaded(
          activeRental: null,
          rentalHistory: history,
          allRentals: all,
        ),
      );
    } on Failure catch (f) {
      emit(RentalActionError(f.message));
      _reloadState(emit);
    } catch (e) {
      emit(RentalActionError(e.toString().replaceAll('Exception: ', '')));
      _reloadState(emit);
    }
  }

  Future<void> _onRequestEarlyExitTenant(
    RequestEarlyExitTenantEvent event,
    Emitter<RentalState> emit,
  ) async {
    try {
      await _chatRepository.sendEarlyExitRequestToTenant(
        tenantId: event.tenantId,
        tenantName: event.tenantName,
        tenantAvatar: event.tenantAvatar,
        listingTitle: event.listingTitle,
        currentUser: event.currentUser,
      );
      emit(
        RentalActionSuccess(
          '${event.tenantName} isimli kiracıya erken çıkış bildirimi mesajı iletildi.',
        ),
      );
      _reloadState(emit);
    } catch (e) {
      emit(RentalActionError('Mesaj gönderilemedi: ${e.toString()}'));
      _reloadState(emit);
    }
  }

  void _reloadState(Emitter<RentalState> emit) {
    final active = _rentalRepository.getActiveRental(tenantId: _currentTenantId);
    final history = _rentalRepository.getRentalHistory(tenantId: _currentTenantId);
    final all = _rentalRepository.getAllRentals();
    emit(
      RentalLoaded(
        activeRental: active,
        rentalHistory: history,
        allRentals: all,
      ),
    );
  }
}
