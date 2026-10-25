import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Sisteme kayıtlı aktif kullanıcıyı getiren Use Case (İş Mantığı).
class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  /// Kullanıcı oturumunu kontrol eder ve varsa UserEntity döner.
  Future<UserEntity?> execute() => repository.getCurrentUser();
}

/// E-posta/kullanıcı adı ve şifre ile giriş yapma Use Case'i.
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  /// Verilen kimlik bilgileriyle oturum açmayı dener.
  Future<UserEntity> execute(String emailOrUsername, String password) =>
      repository.login(emailOrUsername, password);
}

/// Yeni bir kullanıcı hesabı oluşturma Use Case'i.
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  /// Yeni kullanıcı profilini kaydeder ve oturumu başlatır.
  Future<UserEntity> execute(UserEntity user) => repository.register(user);
}

/// Kullanıcı profil bilgilerini güncelleme Use Case'i.
class UpdateProfileUseCase {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  /// Değişen kullanıcı alışkanlıkları ve bilgilerini veritabanına yansıtır.
  Future<UserEntity> execute(UserEntity user) => repository.updateProfile(user);
}

/// Kullanıcı oturumunu kapatma Use Case'i.
class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  /// Oturumu sonlandırır ve yerel anahtarları temizler.
  Future<void> execute() => repository.logout();
}

/// Kullanıcı hesabını kalıcı olarak silme Use Case'i.
class DeleteAccountUseCase {
  final AuthRepository repository;
  DeleteAccountUseCase(this.repository);

  /// Kullanıcı hesabını ve bağlı tüm yerel verilerini siler.
  Future<void> execute() => repository.deleteAccount();
}
