import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/failures.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final UserModel user;
  const RegisterEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class UpdateProfileEvent extends AuthEvent {
  final UserModel user;
  const UpdateProfileEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class UpdateHabitsEvent extends AuthEvent {
  final HabitsModel habits;
  const UpdateHabitsEvent(this.habits);
  @override
  List<Object?> get props => [habits];
}

class AddAddressEvent extends AuthEvent {
  final AddressModel address;
  const AddAddressEvent(this.address);
  @override
  List<Object?> get props => [address];
}

class RemoveAddressEvent extends AuthEvent {
  final String addressId;
  const RemoveAddressEvent(this.addressId);
  @override
  List<Object?> get props => [addressId];
}

class SaveCardEvent extends AuthEvent {
  final SavedCardModel card;
  const SaveCardEvent(this.card);
  @override
  List<Object?> get props => [card];
}

class RemoveCardEvent extends AuthEvent {
  final String cardId;
  const RemoveCardEvent(this.cardId);
  @override
  List<Object?> get props => [cardId];
}

class LogoutEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String message;
  const AuthLoading([this.message = 'İşlem yapılıyor...']);
  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({AuthRepository? repository})
    : _repository = repository ?? AuthRepository(),
      super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateHabitsEvent>(_onUpdateHabits);
    on<AddAddressEvent>(_onAddAddress);
    on<RemoveAddressEvent>(_onRemoveAddress);
    on<SaveCardEvent>(_onSaveCard);
    on<RemoveCardEvent>(_onRemoveCard);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.initDefaultDemoUserIfNeeded();
    final user = _repository.getCurrentUser();
    if (user != null) {
      final users = _repository.getAllRegisteredUsers();
      final exists = users.any(
        (u) =>
            u.id == user.id ||
            u.email.trim().toLowerCase() == user.email.trim().toLowerCase(),
      );
      if (exists) {
        emit(Authenticated(user));
        return;
      } else {
        await _repository.logout();
      }
    }
    emit(Unauthenticated());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Giriş yapılıyor...'));
    try {
      // Simulate brief network delay for polish
      await Future.delayed(const Duration(milliseconds: 600));
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading('Hesap oluşturuluyor...'));
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      final user = await _repository.register(event.user);
      emit(Authenticated(user));
    } on Failure catch (f) {
      emit(AuthError(f.message));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repository.updateProfile(event.user);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateHabits(
    UpdateHabitsEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repository.updateHabits(event.habits);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddAddress(
    AddAddressEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repository.addAddress(event.address);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRemoveAddress(
    RemoveAddressEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repository.removeAddress(event.addressId);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSaveCard(SaveCardEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await _repository.saveCard(event.card);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRemoveCard(
    RemoveCardEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repository.removeCard(event.cardId);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.deleteAccount();
    emit(Unauthenticated());
  }
}
