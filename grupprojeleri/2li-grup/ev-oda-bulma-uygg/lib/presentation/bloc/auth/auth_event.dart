import '../../../domain/entities/user_entity.dart';

/// Kimlik doğrulama ve kullanıcı oturumu için tetiklenen olayların (Events) temel soyut sınıfı.
abstract class AuthEvent {}

/// Uygulama açılışında daha önceden kalıcı bir oturum olup olmadığını denetleyen olay.
class CheckAuthSessionEvent extends AuthEvent {}

/// Kullanıcının giriş formunu doldurup göndermesiyle tetiklenen olay.
class LoginSubmittedEvent extends AuthEvent {
  /// Girilen e-posta veya kullanıcı adı
  final String emailOrUsername;

  /// Girilen şifre
  final String password;

  LoginSubmittedEvent({required this.emailOrUsername, required this.password});
}

/// Yeni bir kullanıcının kayıt olma formunu göndermesiyle tetiklenen olay.
class RegisterSubmittedEvent extends AuthEvent {
  /// Kaydedilecek yeni kullanıcı varlığı
  final UserEntity user;

  RegisterSubmittedEvent({required this.user});
}

/// Kullanıcının profil bilgilerini veya alışkanlık tercihlerini güncellemesi olayı.
class UpdateProfileEvent extends AuthEvent {
  /// Güncellenmiş kullanıcı bilgileri
  final UserEntity user;

  UpdateProfileEvent({required this.user});
}

/// Kullanıcının oturumu kapatma (çıkış yapma) isteği olayı.
class LogoutEvent extends AuthEvent {}

/// Kullanıcının hesabını tamamen silme isteği olayı.
class DeleteAccountEvent extends AuthEvent {}
