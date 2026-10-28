import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Kullanıcı oturumu, kimlik doğrulama, kayıt ve profil güncellemelerini yöneten BLoC sınıfı.
/// UI katmanı ile Domain katmanındaki Use Case'ler arasındaki köprüdür.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
  }) : super(AuthInitialState()) {
    // Olay (Event) dinleyicilerinin tanımlanması
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  /// Uygulama açılışında kayıtlı kullanıcı oturumunu kontrol eder.
  Future<void> _onCheckAuthSession(
      CheckAuthSessionEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await getCurrentUserUseCase.execute();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  /// Kullanıcı giriş formunu gönderdiğinde çalışır ve doğrulama yapar.
  Future<void> _onLoginSubmitted(
      LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // Gerçekçi bir ağ ve yüklenme hissi vermek için kısa bir gecikme simülasyonu
      await Future.delayed(const Duration(milliseconds: 600));
      final user = await loginUseCase.execute(
        event.emailOrUsername,
        event.password,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Yeni kullanıcı kaydını işler ve kullanıcıyı içeri alır.
  Future<void> _onRegisterSubmitted(
      RegisterSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final user = await registerUseCase.execute(event.user);
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Kullanıcının profil bilgilerini günceller ve güncel kullanıcı ile AuthenticatedState yayar.
  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await updateProfileUseCase.execute(event.user);
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Kullanıcının çıkış yapmasını sağlar ve UnauthenticatedState durumuna geçer.
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await logoutUseCase.execute();
    emit(UnauthenticatedState());
  }

  /// Kullanıcı hesabını tamamen siler ve oturumu kapatır.
  Future<void> _onDeleteAccount(
      DeleteAccountEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await deleteAccountUseCase.execute();
    emit(UnauthenticatedState());
  }
}
