import 'dart:math';

import '../../core/security/demo_password_service.dart';
import '../../core/storage/local_store.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class _ResetCodeData {
  final String code;
  final DateTime expiresAt;

  _ResetCodeData({required this.code, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class LocalAuthRepository implements AuthRepository {
  final LocalStore store;
  final DemoPasswordService _passwordService;

  // Bellek içi sıfırlama kodları ve oturumları (diske yazılmaz)
  final Map<String, _ResetCodeData> _pendingCodes = {};
  final Map<String, DateTime> _verifiedSessions = {};

  LocalAuthRepository({
    required this.store,
    DemoPasswordService? passwordService,
  }) : _passwordService = passwordService ?? DemoPasswordService();

  @override
  Future<AppUser?> getActiveUser() async {
    final doc = await store.load();
    if (doc.activeUserId == null) return null;
    try {
      return doc.users.firstWhere((u) => u.id == doc.activeUserId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final normEmail = email.trim().toLowerCase();
    final doc = await store.load();

    AppUser? matchedUser;
    for (final u in doc.users) {
      if (u.email == normEmail) {
        matchedUser = u;
        break;
      }
    }

    if (matchedUser == null) {
      throw Exception(
        'Bu e-posta adresiyle kayıtlı demo kullanıcı bulunamadı.',
      );
    }

    final isValid = await _passwordService.verifyPassword(
      password: password,
      saltHex: matchedUser.passwordSalt,
      expectedHashHex: matchedUser.passwordHash,
    );

    if (!isValid) {
      throw Exception('E-posta veya şifre hatalı.');
    }

    // Aktif kullanıcıyı kaydet
    final updated = doc.copyWith(activeUserId: matchedUser.id);
    await store.save(updated);
    return matchedUser;
  }

  @override
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final normEmail = email.trim().toLowerCase();
    final doc = await store.load();

    final existing = doc.users.any((u) => u.email == normEmail);
    if (existing) {
      throw Exception('Bu e-posta adresi ile zaten bir hesap oluşturulmuş.');
    }

    final salt = _passwordService.generateSalt();
    final hash = await _passwordService.hashPassword(password, salt);
    final userId =
        'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final newUser = AppUser(
      id: userId,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normEmail,
      passwordSalt: salt,
      passwordHash: hash,
      createdAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    // Kayıt sonrası otomatik oturum açılmaz, sadece kullanıcılar listesine eklenir
    final updated = doc.copyWith(users: [...doc.users, newUser]);
    await store.save(updated);
    return newUser;
  }

  @override
  Future<void> logout() async {
    final doc = await store.load();
    final updated = doc.copyWith(clearActiveUser: true);
    await store.save(updated);
    _pendingCodes.clear();
    _verifiedSessions.clear();
  }

  @override
  Future<String?> generateResetCode(String email) async {
    final normEmail = email.trim().toLowerCase();
    final doc = await store.load();
    final exists = doc.users.any((u) => u.email == normEmail);
    if (!exists) {
      throw Exception(
        'Bu e-posta adresiyle eşleşen bir demo hesap bulunamadı.',
      );
    }

    // 6 haneli rastgele kod üret
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();

    // 5 dakika geçerli
    _pendingCodes[normEmail] = _ResetCodeData(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    // Varsa önceki yetkiyi temizle
    _verifiedSessions.remove(normEmail);

    return code;
  }

  @override
  bool verifyResetCode(String email, String code) {
    final normEmail = email.trim().toLowerCase();
    final data = _pendingCodes[normEmail];
    if (data == null) return false;
    if (data.isExpired) {
      _pendingCodes.remove(normEmail);
      return false;
    }
    if (data.code != code.trim()) return false;

    // Kod doğru, 10 dakikalık sıfırlama oturumu aç
    _pendingCodes.remove(normEmail);
    _verifiedSessions[normEmail] = DateTime.now().add(
      const Duration(minutes: 10),
    );
    return true;
  }

  @override
  bool hasValidResetSession(String email) {
    final normEmail = email.trim().toLowerCase();
    final expires = _verifiedSessions[normEmail];
    if (expires == null) return false;
    if (DateTime.now().isAfter(expires)) {
      _verifiedSessions.remove(normEmail);
      return false;
    }
    return true;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final normEmail = email.trim().toLowerCase();
    if (!hasValidResetSession(normEmail)) {
      throw Exception(
        'Sıfırlama oturumunuzun süresi dolmuş veya geçersiz. Lütfen tekrar kod isteyin.',
      );
    }

    final doc = await store.load();
    final userIndex = doc.users.indexWhere((u) => u.email == normEmail);
    if (userIndex == -1) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final salt = _passwordService.generateSalt();
    final hash = await _passwordService.hashPassword(newPassword, salt);

    final oldUser = doc.users[userIndex];
    final updatedUser = oldUser.copyWith(
      passwordSalt: salt,
      passwordHash: hash,
    );

    final updatedUsers = List<AppUser>.from(doc.users);
    updatedUsers[userIndex] = updatedUser;

    // Mevcut oturum varsa kapatılır
    final updated = doc.copyWith(clearActiveUser: true, users: updatedUsers);
    await store.save(updated);

    // Yetki oturumunu tüket
    _verifiedSessions.remove(normEmail);
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final doc = await store.load();
    final userIndex = doc.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) {
      throw Exception('Kullanıcı hesabı bulunamadı.');
    }

    final user = doc.users[userIndex];

    // Mevcut parolayı doğrula
    final isValid = await _passwordService.verifyPassword(
      password: currentPassword,
      saltHex: user.passwordSalt,
      expectedHashHex: user.passwordHash,
    );
    if (!isValid) {
      throw Exception('Mevcut şifreniz hatalı.');
    }

    if (currentPassword == newPassword) {
      throw Exception('Yeni şifre mevcut şifreniz ile aynı olamaz.');
    }

    if (newPassword.length < 8) {
      throw Exception('Yeni şifre en az 8 karakter olmalıdır.');
    }

    // Yeni salt ve hash türet
    final newSalt = _passwordService.generateSalt();
    final newHash = await _passwordService.hashPassword(newPassword, newSalt);

    final updatedUser = user.copyWith(
      passwordSalt: newSalt,
      passwordHash: newHash,
    );

    final updatedUsers = List<AppUser>.from(doc.users);
    updatedUsers[userIndex] = updatedUser;

    // Mevcut oturumu kapatmadan kaydet (oturum sürer)
    final updated = doc.copyWith(users: updatedUsers);
    await store.save(updated);
  }

  @override
  Future<AppUser> updateAvatar({
    required String userId,
    required String avatarId,
  }) async {
    final doc = await store.load();
    final userIndex = doc.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final updatedUser = doc.users[userIndex].copyWith(avatarId: avatarId);
    final updatedUsers = List<AppUser>.from(doc.users);
    updatedUsers[userIndex] = updatedUser;

    final updated = doc.copyWith(users: updatedUsers);
    await store.save(updated);
    return updatedUser;
  }
}
