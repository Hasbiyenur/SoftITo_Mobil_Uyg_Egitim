import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getActiveUser();
  Future<AppUser> login(String email, String password);
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<void> logout();

  /// Demo şifre sıfırlama adımları
  Future<String?> generateResetCode(String email);
  bool verifyResetCode(String email, String code);
  bool hasValidResetSession(String email);
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });
}
