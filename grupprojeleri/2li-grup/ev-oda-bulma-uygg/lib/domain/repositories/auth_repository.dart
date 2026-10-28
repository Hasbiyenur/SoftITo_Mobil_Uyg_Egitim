import '../entities/user_entity.dart';

/// Kimlik doğrulama, oturum ve kullanıcı hesabı işlemlerinin soyut sözleşmesi (Repository Interface).
/// Domain katmanında yer alır ve Clean Architecture gereği somut veri kaynaklarından bağımsızdır.
abstract class AuthRepository {
  /// Sistemde kayıtlı aktif oturum açmış kullanıcıyı getirir.
  /// Oturum yoksa null döner.
  Future<UserEntity?> getCurrentUser();

  /// E-posta/Kullanıcı adı ve şifre ile sisteme giriş yapar.
  /// Başarısızlık durumunda istisna fırlatır, başarılı ise kullanıcı varlığını döner.
  Future<UserEntity> login(String emailOrUsername, String password);

  /// Yeni bir kullanıcı kaydı oluşturur ve sisteme kaydeder.
  Future<UserEntity> register(UserEntity user);

  /// Mevcut kullanıcının profil bilgilerini (alışkanlıklar, iletişim vb.) günceller.
  Future<UserEntity> updateProfile(UserEntity user);

  /// Aktif kullanıcı oturumunu kapatır ve yerel oturum verilerini temizler.
  Future<void> logout();

  /// Kullanıcının hesabını ve ilişkili yerel verilerini kalıcı olarak siler.
  Future<void> deleteAccount();
}
