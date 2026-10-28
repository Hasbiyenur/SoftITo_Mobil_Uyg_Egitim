import '../../../domain/entities/user_entity.dart';

/// Kimlik doğrulama akışındaki durumların (States) temel soyut sınıfı.
abstract class AuthState {}

/// Başlangıç durumu; henüz bir işlem yapılmamışken geçerlidir.
class AuthInitialState extends AuthState {}

/// Kimlik doğrulama işlemi sürerken gösterilen yüklenme durumu.
class AuthLoadingState extends AuthState {}

/// Kullanıcının başarıyla giriş yaptığı veya oturumunun doğrulandığı durum.
class AuthenticatedState extends AuthState {
  /// Aktif oturum açmış kullanıcı nesnesi
  final UserEntity user;

  AuthenticatedState(this.user);
}

/// Giriş yapılmamış veya oturumu sonlandırılmış durum.
class UnauthenticatedState extends AuthState {}

/// Giriş, kayıt veya güncelleme işlemlerinde hata oluştuğunu bildiren durum.
class AuthErrorState extends AuthState {
  /// Kullanıcıya gösterilecek hata mesajı
  final String message;

  AuthErrorState(this.message);
}
